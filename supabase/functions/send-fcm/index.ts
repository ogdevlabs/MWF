import "@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

// Base64url encode a Uint8Array
function base64urlEncode(bytes: Uint8Array): string {
  const base64 = btoa(String.fromCharCode(...bytes));
  return base64.replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
}

// Create and sign a JWT for Google OAuth2 token exchange
async function getFcmAccessToken(): Promise<string> {
  const serviceAccountJson = Deno.env.get("FIREBASE_SERVICE_ACCOUNT_JSON");
  if (!serviceAccountJson) {
    throw new Error("FIREBASE_SERVICE_ACCOUNT_JSON env var not set");
  }

  const serviceAccount = JSON.parse(serviceAccountJson);
  const { client_email, private_key } = serviceAccount;

  const now = Math.floor(Date.now() / 1000);

  // JWT header
  const header = { alg: "RS256", typ: "JWT" };
  const headerB64 = base64urlEncode(
    new TextEncoder().encode(JSON.stringify(header))
  );

  // JWT payload
  const payload = {
    iss: client_email,
    sub: client_email,
    aud: "https://oauth2.googleapis.com/token",
    iat: now,
    exp: now + 3600,
    scope: "https://www.googleapis.com/auth/firebase.messaging",
  };
  const payloadB64 = base64urlEncode(
    new TextEncoder().encode(JSON.stringify(payload))
  );

  const signingInput = `${headerB64}.${payloadB64}`;

  // Import the private key (PEM format) for RSA-PKCS1v1.5 signing
  const pemBody = private_key
    .replace(/-----BEGIN PRIVATE KEY-----/, "")
    .replace(/-----END PRIVATE KEY-----/, "")
    .replace(/\s/g, "");
  const pkDer = Uint8Array.from(atob(pemBody), (c) => c.charCodeAt(0));

  const cryptoKey = await crypto.subtle.importKey(
    "pkcs8",
    pkDer,
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"]
  );

  const signature = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    cryptoKey,
    new TextEncoder().encode(signingInput)
  );

  const signatureB64 = base64urlEncode(new Uint8Array(signature));
  const jwt = `${signingInput}.${signatureB64}`;

  // Exchange JWT for access token
  const tokenResponse = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: `grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Ajwt-bearer&assertion=${jwt}`,
  });

  if (!tokenResponse.ok) {
    const errorText = await tokenResponse.text();
    throw new Error(`OAuth2 token exchange failed: ${errorText}`);
  }

  const tokenData = await tokenResponse.json();
  return tokenData.access_token as string;
}

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  let body: { threadId: string; studentId: string };
  try {
    body = await req.json();
  } catch {
    return Response.json({ error: "Invalid JSON body" }, { status: 400 });
  }

  const { threadId, studentId } = body;
  if (!threadId || !studentId) {
    return Response.json(
      { error: "threadId and studentId are required" },
      { status: 400 }
    );
  }

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
  );

  // Fetch the student's FCM token
  const { data: student, error: studentError } = await supabase
    .from("students")
    .select("fcm_token")
    .eq("id", studentId)
    .single();

  if (studentError || !student?.fcm_token) {
    return Response.json({ sent: false, reason: "no_token" });
  }

  const firebaseProjectId = Deno.env.get("FIREBASE_PROJECT_ID");
  if (!firebaseProjectId) {
    return Response.json(
      { error: "FIREBASE_PROJECT_ID env var not set" },
      { status: 500 }
    );
  }

  // Get FCM access token via service account JWT
  let accessToken: string;
  try {
    accessToken = await getFcmAccessToken();
  } catch (err) {
    console.error("Failed to get FCM access token:", err);
    return Response.json(
      { sent: false, reason: "auth_error", error: String(err) },
      { status: 500 }
    );
  }

  // Send FCM v1 push notification
  const fcmResponse = await fetch(
    `https://fcm.googleapis.com/v1/projects/${firebaseProjectId}/messages:send`,
    {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${accessToken}`,
      },
      body: JSON.stringify({
        message: {
          token: student.fcm_token,
          notification: {
            title: "Coach replied",
            body: "Your coach has replied to your feedback.",
          },
          data: { type: "coach_reply", threadId },
        },
      }),
    }
  );

  // Update notification_sent flag if FCM delivery succeeded
  if (fcmResponse.ok) {
    await supabase
      .from("feedback_threads")
      .update({ notification_sent: true })
      .eq("id", threadId);
  } else {
    const fcmError = await fcmResponse.text();
    console.error("FCM delivery failed:", fcmError);
  }

  return Response.json({ sent: fcmResponse.ok, status: fcmResponse.status });
});
