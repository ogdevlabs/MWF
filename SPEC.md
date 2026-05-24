# Feature Specification: Mat Pilates Coach — Student Mobile App

**Feature Branch**: `001-mat-pilates-coach-student-app`

**Created**: 2026-05-24

**Status**: Draft

**Platform**: Flutter (iOS + Android)

---

## User Scenarios & Testing *(mandatory)*

<!--
  User stories are prioritized as independent, testable slices.
  P1 = MVP blocker. Each story delivers standalone value.
-->

### User Story 1 — Enroll & Access a Program (Priority: P1)

A new student downloads the app, creates an account, selects a subscription plan,
and gains access to a coach-designed multi-week Mat Pilates program.

**Why this priority**: Without enrollment and access gating, the app delivers no
value and the coach cannot monetize content.

**Independent Test**: A new user can sign up, subscribe via in-app purchase, and
land on a program overview screen with all sessions listed.

**Acceptance Scenarios**:

1. **Given** the app is freshly installed, **When** the user taps "Get Started",
   **Then** they see onboarding screens followed by account creation (email +
   password or social login).
2. **Given** the user has created an account, **When** they view available programs,
   **Then** locked programs display a paywall; subscribed programs are accessible.
3. **Given** a user subscribes via in-app purchase (App Store / Google Play),
   **When** payment is confirmed, **Then** all programs included in the plan unlock
   immediately without requiring an app restart.
4. **Given** a user's subscription lapses, **When** they open the app,
   **Then** program content is locked and they are prompted to resubscribe.

---

### User Story 2 — Follow a Structured Program Day by Day (Priority: P1)

A subscribed student opens their active program, sees today's session in the
coach-designed sequence, and completes it step by step.

**Why this priority**: This is the core daily habit loop the entire app is built
around.

**Independent Test**: A subscribed user can open a program, tap "Today's Session",
progress through every exercise, and reach a completion screen — entirely offline
if content was previously synced.

**Acceptance Scenarios**:

1. **Given** a subscribed student opens the app, **When** they view their active
   program, **Then** the current day's session is highlighted and accessible; past
   sessions are marked complete; future sessions are visible but locked.
2. **Given** a student starts a session, **When** an exercise loads, **Then** a
   video plays automatically alongside a 3D animation companion (form reference)
   with rep count or timer displayed as an overlay.
3. **Given** a student finishes all exercises in a session, **When** the last
   exercise ends, **Then** a completion screen appears with a summary (duration,
   exercises completed) and the session is marked done in the program calendar.
4. **Given** a student pauses mid-session, **When** they re-open the app,
   **Then** they resume from the last incomplete exercise.

---

### User Story 3 — Offline-First Workout (Priority: P1)

A student pre-syncs program content and completes a session with no internet
connection; progress syncs when connectivity is restored.

**Why this priority**: Pilates is often done in spaces with unreliable connectivity
(studios, gyms, outdoors); offline support is a core promise.

**Independent Test**: With airplane mode enabled after initial sync, a student can
complete a full session; when reconnected, the completion is reflected in their
progress history.

**Acceptance Scenarios**:

1. **Given** a student is on Wi-Fi, **When** they open a program, **Then** the app
   silently pre-downloads upcoming session videos and assets in the background.
2. **Given** the device is offline, **When** the student opens a pre-synced session,
   **Then** videos and 3D animations play normally with no error state.
3. **Given** offline progress was recorded, **When** the device reconnects,
   **Then** completed sessions, metrics, and feedback drafts sync to the server
   automatically.
4. **Given** a session has not been downloaded, **When** the student attempts to
   open it offline, **Then** the app shows a clear "Download required" message with
   an option to download when connectivity returns.

---

### User Story 4 — Track Body Metrics & Performance Over Time (Priority: P2)

A student logs personal metrics (weight, measurements, flexibility scores) and views
their progress through charts tied to their program timeline.

**Why this priority**: Long-term retention depends on students seeing tangible
improvement over the course of a program.

**Independent Test**: A student can log a metric entry, view a chart of entries over
time, and see the delta between their first and latest log.

**Acceptance Scenarios**:

1. **Given** a student opens the Progress section, **When** they tap "Log Metrics",
   **Then** they can enter values for weight, body measurements, and flexibility
   scores with a date stamp.
2. **Given** at least two metric entries exist, **When** the student views the
   Progress chart, **Then** a line chart displays the trend over the program duration.
3. **Given** a student completes a session, **When** the completion screen appears,
   **Then** they are prompted (non-blocking) to log any metrics for that day.
4. **Given** a student views their program overview, **When** they navigate to
   Progress, **Then** both session completion streaks and metric trends are visible
   on the same dashboard.

---

### User Story 5 — Submit Session Notes & Receive Coach Feedback (Priority: P2)

After completing a session, a student can submit written notes or photos to the
coach; the coach can reply through the admin panel and the student sees the response
in-app.

**Why this priority**: The feedback loop differentiates this app from generic fitness
content and drives student retention.

**Independent Test**: A student submits a note on a completed session; using the
admin panel a coach posts a reply; the student sees the reply as a notification and
within the session detail view.

**Acceptance Scenarios**:

1. **Given** a session is marked complete, **When** the student views its detail
   page, **Then** a "Send to Coach" input is available for text and optional photo
   attachment.
2. **Given** a student submits feedback, **When** the coach replies via the admin
   panel, **Then** the student receives a push notification and sees the reply
   threaded below their original note.
3. **Given** no internet connection, **When** a student writes a note,
   **Then** the note is saved locally and submitted automatically when the device
   reconnects.
4. **Given** a student has received coach replies, **When** they open the
   Notifications screen, **Then** all coach replies are listed chronologically with
   links to the relevant session.

---

### User Story 6 — Coach Creates & Publishes a Program (Priority: P2)

A coach uses the admin panel (web-based) to create a multi-week program, upload
videos and 3D assets for exercises, and publish it for subscribed students.

**Why this priority**: Without content creation, there is nothing for students to
consume.

**Independent Test**: A coach creates a 4-week program with at least one session and
one exercise (video + 3D asset), publishes it, and a subscribed student can see and
play it in the mobile app.

**Acceptance Scenarios**:

1. **Given** a coach is logged into the admin panel, **When** they create a program,
   **Then** they can define name, description, difficulty level, duration (weeks),
   and thumbnail image.
2. **Given** a program exists, **When** the coach adds a session, **Then** they can
   set a day number, title, and add ordered exercises each with a video upload, 3D
   model asset, rep/time parameters, and written cues.
3. **Given** a program is in Draft state, **When** the coach taps Publish,
   **Then** the program becomes visible to subscribed students in the mobile app
   within 60 seconds.
4. **Given** a published program has a video updated, **When** the update is saved,
   **Then** the new video is served to students; previously downloaded versions are
   invalidated and re-downloaded on next sync.

---

### Edge Cases

- What happens when a video download is interrupted mid-session (e.g., airplane mode
  toggled during background sync)?
- How does the app handle a student attempting to access content while a subscription
  is being verified (grace period)?
- What if the 3D animation asset fails to load — does the video still play solo?
- How does streak counting behave when a student completes a session on a different
  timezone than the one they enrolled in?
- What happens if the coach deletes a session that a student has already completed?
- How are simultaneous logins across two devices handled (e.g., phone + tablet)?

---

## Requirements *(mandatory)*

### Functional Requirements

**Student App (Mobile — Flutter)**

- **FR-001**: System MUST support account creation via email/password and social
  login (Apple, Google).
- **FR-002**: System MUST gate program content behind an active subscription,
  verified via App Store / Google Play in-app purchase receipts.
- **FR-003**: Students MUST be able to browse available programs with title,
  description, duration, difficulty, and subscription status.
- **FR-004**: System MUST present each program as a sequential day-by-day session
  list where future sessions are locked until previous ones are complete.
- **FR-005**: Each session MUST display exercises in order, each with: video player,
  3D animation companion panel, rep/time overlay, and written cues.
- **FR-006**: System MUST support offline-first operation; all session content
  (video, 3D assets, metadata) MUST be pre-downloadable for offline playback.
- **FR-007**: System MUST sync offline progress (completions, metrics, feedback
  drafts) automatically when connectivity is restored.
- **FR-008**: Students MUST be able to log body metrics (weight, measurements,
  flexibility scores) with date stamps.
- **FR-009**: System MUST display metric trends as line charts over the program
  timeline.
- **FR-010**: Students MUST be able to submit session feedback (text + optional
  photo) after completing a session.
- **FR-011**: System MUST deliver push notifications for coach replies to feedback.
- **FR-012**: System MUST display a completion screen with session summary after all
  exercises are finished.
- **FR-013**: System MUST resume a partially completed session from the last
  incomplete exercise.
- **FR-014**: System MUST maintain a streak counter based on consecutive days with
  completed sessions.

**Admin Panel (Web — Coach-Facing)**

- **FR-015**: Coach MUST be able to create, edit, and delete programs with metadata
  (title, description, difficulty, thumbnail, duration).
- **FR-016**: Coach MUST be able to add sessions to programs with ordered exercises,
  each having a video upload, 3D asset upload, rep/time config, and text cues.
- **FR-017**: Coach MUST be able to publish/unpublish programs; published programs
  appear in the student app within 60 seconds.
- **FR-018**: Coach MUST be able to view student feedback submissions and post
  replies.
- **FR-019**: System MUST invalidate cached video assets on student devices when a
  video is updated by the coach.

### Key Entities

- **Student**: account credentials, subscription status, enrolled programs, progress
  records, metric logs, feedback threads.
- **Program**: title, description, difficulty, duration (weeks), thumbnail,
  publish status, ordered list of Sessions.
- **Session**: day number, title, ordered list of Exercises, completion status per
  student.
- **Exercise**: video URL, 3D asset reference, rep count or duration (seconds),
  written cues, display order within session.
- **ProgressRecord**: student ID, session ID, completed timestamp, duration taken.
- **MetricLog**: student ID, date, metric type (weight / measurement / flexibility),
  value, unit.
- **FeedbackThread**: student ID, session ID, student message, optional photo URL,
  coach reply, timestamps.
- **Subscription**: student ID, plan ID, store receipt, valid-until timestamp,
  status (active / expired / cancelled).

---

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A new student can complete signup, subscribe, and begin their first
  session in under 3 minutes from cold app launch.
- **SC-002**: Session video playback starts within 2 seconds when content is
  pre-downloaded; within 5 seconds on a 4G connection.
- **SC-003**: 3D animation companion loads and renders within 1 second of session
  screen opening.
- **SC-004**: Offline completion records sync to the server within 10 seconds of
  reconnection.
- **SC-005**: A coach can create and publish a complete single-session program in
  under 15 minutes via the admin panel.
- **SC-006**: Push notifications for coach replies are delivered within 60 seconds
  of the coach posting a reply.
- **SC-007**: App store ratings target ≥ 4.5 stars based on onboarding and
  workout-playback experience.
- **SC-008**: Student 30-day retention rate target ≥ 60% for active subscribers.

---

## Assumptions

- The coach operates a single-brand studio; the app is not a multi-tenant
  marketplace.
- Video hosting and CDN are provided by a cloud service (e.g., Cloudflare Stream,
  Mux, or AWS CloudFront); the spec does not dictate which.
- 3D animation assets are pre-authored (e.g., exported glTF/GLB files) by the coach
  or a designer; the admin panel uploads but does not create them.
- In-app purchases follow Apple and Google's standard subscription models;
  no direct payment processing (Stripe, etc.) is handled in-app.
- The admin panel is a web application (not a mobile app); its detailed spec is
  outside this document's scope but is a prerequisite for the student app.
- Social login providers (Apple, Google) are required for App Store compliance
  (Apple Sign-In is mandatory when other social logins are offered on iOS).
- Background video pre-download respects device storage warnings and pauses if
  available storage falls below a configurable threshold (default: 500 MB).
- The app supports iOS 16+ and Android 10+ (API 29+) at launch.
- Accessibility (screen reader support, minimum contrast ratios) follows WCAG 2.1 AA
  for all non-video content.
