

// RevenueCat webhook stub
// TODO Phase 3: Validate X-RevenueCat-Signature header using REVENUECAT_WEBHOOK_SECRET
// TODO Phase 3: Upsert subscriptions table on purchase/renewal/cancellation events
// Payload shape: { event: { type: string, subscriber_info: {...} } }

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  const body = await req.json();
  console.log("RevenueCat webhook received:", body.event?.type);

  return Response.json({ received: true });
});
