# 📋 **JAM Application Implementation Plan**

## **Phase 1: Project Setup & Infrastructure**
1. **Initialize Phoenix Project**
   - Create new Phoenix 1.8.1 project with LiveView
   - Configure PostgreSQL database
   - Set up Tailwind CSS + DaisyUI + Heroicons
   - Configure development/test/production environments

2. **Dependencies Setup**
   - Add all required dependencies (Telegex, Swoosh, Req, Oban, Ecto)
   - Configure Oban for background jobs
   - Set up Swoosh for email delivery
   - Configure CSRF protection

3. **Database Foundation**
   - Create initial migration structure
   - Set up Ecto repos and configuration

---

## **Phase 2: Authentication & User System**
4. **User Schema & Context**
   - Create `users` table with all fields from spec
   - Implement `Accounts` context
   - Add user registration/login functions
   - Set up password hashing (optional passwords)

5. **Passwordless Authentication**
   - Implement magic link generation with Phoenix.Token
   - Create email templates for magic links
   - Build login/register LiveView pages
   - Configure 14-day session persistence

6. **Authorization System**
   - Create authorization plugs (`EnsureSuperadminPlug`, `EnsureOwnerOrCoorganizerPlug`)
   - Implement role-based access control
   - Add user blocking functionality

---

## **Phase 3: Core JAM System**
7. **Jam Series Schema & Context**
   - Create `jam_series` table with all fields
   - Create `jam_series_coorganizers` join table
   - Implement `Jams` context with CRUD operations
   - Add Google Maps/Places API integration for location

8. **Jam Sessions Schema**
   - Create `jam_sessions` table
   - Link to jam_series (belongs_to relationship)
   - Handle custom overrides (cost, location, capacity)
   - Implement status management (scheduled/cancelled/completed)

9. **Co-organizer System**
   - Create signed invite token generation
   - Build invite link handling with 48h expiration
   - Implement co-organizer association logic
   - Handle both registered and new user invitations

---

## **Phase 4: Booking System**
10. **Registration Schema & Context**
    - Create `registrations` table
    - Implement `Bookings` context
    - Add capacity management (separate base/flyer)
    - Generate secure cancellation tokens

11. **Waitlist Management**
    - Implement waitlist logic and positioning
    - Create automatic promotion system
    - Handle status transitions (confirmed/waitlist/cancelled)
    - Build waitlist notification system

---

## **Phase 5: Telegram Bot Integration**
12. **Bot Setup & Configuration**
    - Initialize Telegex bot
    - Configure webhook or polling
    - Set up deep link handling (`t.me/jamapp_bot?start=...`)
    - Link Telegram users to app accounts via `telegram_user_id`

13. **Bot Commands & Interactions**
    - Implement `/start` command with deep link parsing
    - Create jam listing view
    - Build registration/cancellation flows
    - Add share functionality

14. **Telegram Notifications**
    - Create `Notifications` context
    - Implement notification templates
    - Build TelegramNotifyJob for async messaging
    - Handle confirmation, promotion, cancellation, reminder messages

---

## **Phase 6: Background Jobs (Oban)**
15. **Job Workers**
    - Create `ReminderJob` (24h before event)
    - Create `PromotionJob` (waitlist promotion)
    - Create `CleanupJob` (archive past events)
    - Create `TelegramNotifyJob` (async Telegram messages)
    - Configure job scheduling and retry logic

---

## **Phase 7: LiveView UI/UX**
16. **Dashboard & Navigation**
    - Create main dashboard LiveView
    - Show personal and co-organized events
    - Implement mobile-first responsive design
    - Add light/dark theme toggle

17. **Jam Series Management**
    - Create/edit jam series LiveView forms
    - Add photo upload functionality
    - Implement location picker with Google Maps
    - Build co-organizer invitation interface

18. **Jam Session Management**
    - Create session scheduling interface
    - Build calendar view for sessions
    - Add custom override forms
    - Implement status management UI

19. **Registration Management**
    - Create registration table with filters/search
    - Show capacity and waitlist status
    - Add manual registration entry
    - Build export functionality

20. **Public Pages**
    - Create public jam session detail page
    - Build public registration form
    - Implement cancellation page (via token)

---

## **Phase 8: Email System**
21. **Email Templates**
    - Magic link email
    - Registration confirmation
    - Waitlist promotion notification
    - Cancellation confirmation
    - 24h reminder email
    - Co-organizer invitation email

22. **Email Delivery**
    - Configure Swoosh with Postmark
    - Set up email sending jobs
    - Implement delivery tracking

---

## **Phase 9: Testing & Quality**
23. **Unit Tests**
    - Test all contexts (Accounts, Jams, Bookings, Notifications)
    - Test authorization logic
    - Test capacity and waitlist algorithms

24. **Integration Tests**
    - Test LiveView interactions
    - Test Telegram bot flows
    - Test email delivery
    - Test background jobs

25. **End-to-End Tests**
    - Test complete user journeys
    - Test co-organizer workflows
    - Test registration and cancellation flows

---

## **Phase 10: Deployment & Documentation**
26. **Production Setup**
    - Configure production environment
    - Set up database migrations
    - Configure secrets and environment variables
    - Set up monitoring and logging

27. **Documentation**
    - API documentation
    - User guide
    - Admin guide
    - Deployment guide
    - Create ER diagram (Mermaid format)

---

## **Estimated Timeline**
- **Phase 1-2**: 1-2 weeks (Setup + Auth)
- **Phase 3-4**: 2-3 weeks (Core JAM + Bookings)
- **Phase 5**: 1-2 weeks (Telegram)
- **Phase 6**: 1 week (Background Jobs)
- **Phase 7**: 2-3 weeks (UI/UX)
- **Phase 8**: 1 week (Email)
- **Phase 9**: 2 weeks (Testing)
- **Phase 10**: 1 week (Deployment)

**Total**: ~11-15 weeks

---

## **Priority Order for MVP**
1. User auth (magic links)
2. Jam Series + Sessions CRUD
3. Basic registration system
4. Email notifications
5. LiveView UI for management
6. Public registration pages
7. Telegram bot (can be added later)
8. Background jobs optimization

---

## **Technical Implementation Notes**

### **Context Structure**
```
lib/jamie/
├── accounts/          # User management & auth
├── jams/             # Jam series, sessions, co-organizers
├── bookings/         # Registrations & waitlist
├── notifications/    # Email & Telegram
└── authorization/    # Roles & permissions
```

### **Key Database Tables**
- `users`
- `jam_series`
- `jam_series_coorganizers`
- `jam_sessions`
- `registrations`

### **Background Jobs (Oban)**
- `Jamie.Workers.ReminderJob`
- `Jamie.Workers.PromotionJob`
- `Jamie.Workers.CleanupJob`
- `Jamie.Workers.TelegramNotifyJob`

### **LiveView Pages**
- Dashboard (`/`)
- Jam Series CRUD (`/jams/*`)
- Jam Session management (`/jams/:id/sessions/*`)
- Registration management (`/jams/:id/sessions/:session_id/registrations`)
- Public registration (`/register/:token`)
- Auth pages (`/login`, `/register`)

---

This plan follows a logical progression where each phase builds upon the previous one, allowing for incremental development and testing.
