# 📋 **Specifiche Complete dell'Applicazione JAM (v3)**

## 🏗️ **Architettura Generale**

### **Stack Tecnologico**

* **Backend**: Elixir / Phoenix 1.8.1
* **Database**: PostgreSQL + Ecto 3.13
* **Frontend**: Phoenix LiveView 1.1.0 + Tailwind CSS + DaisyUI
* **Bot Telegram**: Telegex 1.8
* **Email**: Swoosh 1.16
* **HTTP Client**: Req 0.5
* **Background Jobs**: Oban 2.19
* **Authentication**: Passwordless (Magic Links) + optional password
* **Styling**: Tailwind CSS + Heroicons

---

## 👥 **Sistema Utenti e Autenticazione**

### **Modello User**

```elixir
%User{
  email: string,                    # Unico, obbligatorio
  hashed_password: string,          # Opzionale (passwordless)
  confirmed_at: datetime,           # Conferma email
  telegram_user_id: integer,        # ID Telegram (opzionale)
  role: [:superadmin, :user],       
  blocked: boolean,                 # Blocco utente
  name: string,
  surname: string,
  phone: string,
  preferred_role: "base" | "flyer"
}
```

### **Ruoli e Permessi**

| Ruolo          | Descrizione            | Permessi                                                        |
| -------------- | ---------------------- | --------------------------------------------------------------- |
| **Superadmin** | Amministratore globale | Può vedere e gestire qualsiasi utente o evento                  |
| **User**       | Utente normale         | Può creare e gestire i propri eventi, invitare co-organizzatori |

### **Autenticazione**

* **Magic Links** via email (default)
* **Password tradizionale** opzionale
* **Sessione persistente**: 14 giorni
* **Logout**: invalidazione sessione
* **CSRF Protection**: abilitata di default

---

## 🎪 **Sistema JAM**

### Struttura logica

Il sistema gestisce due livelli di eventi:

1. **Jam Series (ricorrenti)** → es. *“Jam del Lunedì allo Studio Moma”*
2. **Jam Sessions (singole date)** → es. *“Jam del Lunedì 20 Ottobre alle 21:00”*

---

### **Jam Series**

```elixir
%JamSeries{
  id: uuid,
  title: string,                   # es. "Jam del Lunedì allo Studio Moma"
  description: string,             # markdown
  location: string,
  latitude: decimal,
  longitude: decimal,
  google_place_id: string,
  cost: decimal,
  photo_url: string,
  base_capacity: integer | nil,
  flyer_capacity: integer | nil,
  subscription_message: string,
  cancellation_message: string,
  disabled: boolean,
  created_by_id: user_id
}
```

#### **Relazioni**

* `has_many :jam_sessions, JamSession`
* `has_many :coorganizers, through: :jam_series_coorganizers`

#### **Regole**

* Qualunque user può creare una nuova `JamSeries`.
* L’utente che la crea ne diventa automaticamente il **proprietario**.
* Può invitare altri utenti come **co-organizzatori** (con pari permessi su quella serie).

---

### **Jam Sessions**

```elixir
%JamSession{
  id: uuid,
  jam_series_id: uuid,
  date: datetime,
  custom_cost: decimal | nil,
  custom_location: string | nil,
  custom_capacity: integer | nil,
  status: "scheduled" | "cancelled" | "completed",
  note: string
}
```

#### **Regole**

* Viene creata partendo da una `JamSeries`, ereditandone i dati base.
* Alcuni campi (costo, location, capacità) possono essere sovrascritti.
* Quando l’evento termina o viene annullato → stato aggiornato automaticamente.

---

### **Co-organizer System**

#### **Tabella: jam_series_coorganizers**

```elixir
%JamSeriesCoorganizer{
  jam_series_id: uuid,
  user_id: uuid,
  invited_by_id: uuid,
  inserted_at: datetime
}
```

#### **Logica Inviti**

* Il creatore può invitare co-organizzatori tramite **link d’invito firmato**:

  ```
  https://jamapp.com/register?invite_token=<signed_token>
  ```
* Il token include:

  * `jam_series_id`
  * `invited_by_id`
  * scadenza (es. 48h)
* Se l’invitato non è registrato → flusso di signup automatico
* Se l’invitato è già registrato → associazione diretta alla serie

---

## 📝 **Sistema Prenotazioni**

### **Registrations**

```elixir
%Registration{
  jam_session_id: uuid,
  name: string,
  surname: string,
  phone: string,
  role: "base" | "flyer",
  status: "confirmed" | "waitlist" | "cancelled",
  waitlist_position: integer,
  telegram_user_id: integer | nil,
  email: string,
  cancellation_token: string
}
```

### **Logica**

* Capacità separate per base e flyer.
* Quando pieno → nuovi iscritti vanno in waitlist.
* Promozione automatica dalla waitlist appena si libera un posto.
* Cancellazione tramite token sicuro ricevuto via email o Telegram.
* Status automatico: `completed` quando tutti i posti sono occupati.

---

## 🤖 **Integrazione Telegram**

### **Funzionalità Bot**

* Gli utenti possono:

  * visualizzare le jam attive
  * iscriversi o annullare l’iscrizione
  * ricevere conferme e promemoria
  * condividere eventi con altri
* Il bot usa **deep links**:

  ```
  t.me/jamapp_bot?start=series_<id>_session_<id>
  ```
* Collegamento Telegram ↔️ account tramite `telegram_user_id`.
* Notifiche asincrone via Oban Jobs:

  * conferma iscrizione
  * promozione da waitlist
  * cancellazione
  * reminder 24h prima

---

## 🔐 **Autorizzazione**

### **Regole Base**

| Ruolo      | Può creare Jam | Può gestire tutte | Può gestire Jam create o condivise   |
| ---------- | -------------- | ----------------- | ------------------------------------ |
| Superadmin | ✅              | ✅                 | ✅                                    |
| User       | ✅              | ❌                 | ✅ (solo le proprie o co-organizzate) |

### **Plug di Autorizzazione**

* `EnsureOwnerOrCoorganizerPlug` → verifica se l’utente ha diritto di gestire la JamSeries
* `EnsureSuperadminPlug` → per aree riservate

---

## 🧠 **Automazioni (Background Jobs)**

* **ReminderJob** → invio promemoria (24h prima)
* **PromotionJob** → promozione automatica dalla waitlist
* **CleanupJob** → archivia eventi passati
* **TelegramNotifyJob** → invio messaggi Telegram asincroni

---

## 🎨 **UI/UX**

* Dashboard eventi (personali e co-organizzati)
* Calendario jam
* Moduli LiveView per creazione e modifica
* Tabelle prenotazioni con filtro e ricerca
* Tema chiaro/scuro
* Interfaccia mobile-first

---

## 📊 **Integrazioni**

* **Google Maps / Places API** per localizzazione
* **Telegram Bot API** per interazione utenti
* **Oban** per automazioni e notifiche
* **Swoosh + Postmark** per invii email

---

## 🧩 **Struttura Context**

* `Accounts` → utenti, autenticazione
* `Jams` → jam series, jam sessions, co-organizzatori
* `Bookings` → registrazioni e waitlist
* `Notifications` → Telegram / email
* `Authorization` → ruoli e permessi

---

Vuoi che ti prepari ora anche il **diagramma ER (Entity Relationship)** in formato **Mermaid**, basato su questa versione “semplificata a due ruoli”?
Sarebbe utile per documentare subito la struttura aggiornata.
