# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Jamie.Repo.insert!(%Jamie.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Jamie.Repo
alias Jamie.Accounts
alias Jamie.Occurences

# Clear existing data (optional - comment out if you want to keep existing data)
IO.puts("Clearing existing data...")
Repo.delete_all(Occurences.Participant)
Repo.delete_all(Occurences.Coorganizer)
Repo.delete_all(Occurences.Occurence)
Repo.delete_all(Accounts.User)

IO.puts("Creating users...")

# Create main user (Danilo)
{:ok, danilo} =
  Accounts.register_user(%{
    email: "danilo@example.com",
    password: "password123456",
    name: "Danilo",
    surname: "Silva",
    phone: "+39393333333",
    preferred_role: "base"
  })

{:ok, danilo} = Accounts.confirm_user(danilo)
{:ok, _danilo} = Accounts.update_user_profile(danilo, %{nickname: "danilo"})

# Create second user (Giuseppe)
{:ok, giuseppe} =
  Accounts.register_user(%{
    email: "giuseppe@example.com",
    password: "password123456",
    name: "Giuseppe",
    surname: "Verdi",
    preferred_role: "base"
  })

{:ok, giuseppe} = Accounts.confirm_user(giuseppe)
{:ok, _giuseppe} = Accounts.update_user_profile(giuseppe, %{nickname: "Giuseppe"})

# Create third user (Maria)
{:ok, maria} =
  Accounts.register_user(%{
    email: "maria@example.com",
    password: "password123456",
    name: "Maria",
    surname: "Mocciola",
    phone: "+43242342",
    preferred_role: "flyer"
  })

{:ok, maria} = Accounts.confirm_user(maria)

IO.puts("Creating events...")

# Create past event
{:ok, _past1} =
  Occurences.create_occurence(%{
    title: "Past Jazz Session",
    description: "A great jazz session that already happened",
    date: DateTime.add(DateTime.utc_now(), -5, :day),
    status: "completed",
    created_by_id: danilo.id,
    is_private: false,
    show_available_spots: true,
    show_partecipant_list: false
  })

{:ok, _past2} =
  Occurences.create_occurence(%{
    title: "Last Week Jam",
    description: "Another past event",
    date: DateTime.add(DateTime.utc_now(), -10, :day),
    status: "completed",
    created_by_id: danilo.id,
    is_private: false,
    show_available_spots: true,
    show_partecipant_list: false
  })

# Create upcoming event with full details (Jam al BAM)
{:ok, jam_bam} =
  Occurences.create_occurence(%{
    title: "Jam al BAM",
    description: """
    # Jam Session at BAM

    Join us for an amazing jam session at the beautiful BAM park!

    ## What to bring:
    - Your own mat/blanket
    - Water to drink
    - Bug spray!

    ## Guidelines:
    - Be respectful of others
    - Keep the area clean
    - Have fun!
    """,
    location: "BAM - Biblioteca degli Alberi Milano",
    latitude: Decimal.new("45.48456410"),
    longitude: Decimal.new("9.19260720"),
    google_place_id: "ChIJ90iZT83GhkcRXLqkHmqRL2w",
    photo_url: "https://lh3.googleusercontent.com/p/AF1QipMVrQaJWrL6KOKPTR7aBeyOkyT55oPc3zkn6bKF=s1360-w1360-h1020-rw",
    cost: nil,
    base_capacity: 10,
    flyer_capacity: 5,
    subscription_message: "Welcome! We're excited to have you join us. See you at BAM!",
    cancellation_message: "We're sorry you can't make it. Hope to see you at the next session!",
    sare_message: "Join our Jam Session at BAM! Free entry, bring your instruments and good vibes!",
    date: DateTime.add(DateTime.utc_now(), 7, :day),
    status: "scheduled",
    note: "Internal: Remember to bring extra mics and the portable speaker",
    created_by_id: danilo.id,
    is_private: false,
    show_available_spots: true,
    show_partecipant_list: false
  })

# Create New Year's Eve event
{:ok, _nye} =
  Occurences.create_occurence(%{
    title: "New Year's Eve Special",
    description: "Ring in the new year with music!",
    location: "BAM - Biblioteca degli Alberi Milano",
    latitude: Decimal.new("45.48456410"),
    longitude: Decimal.new("9.19260720"),
    google_place_id: "ChIJ90iZT83GhkcRXLqkHmqRL2w",
    cost: Decimal.new("25.00"),
    base_capacity: 50,
    flyer_capacity: 20,
    date: ~U[2025-12-31 20:00:00Z],
    status: "scheduled",
    created_by_id: danilo.id,
    is_private: false,
    show_available_spots: true,
    show_partecipant_list: false
  })

# Create a private event
{:ok, _private} =
  Occurences.create_occurence(%{
    title: "Private Band Rehearsal",
    description: "Closed rehearsal for band members only",
    date: DateTime.add(DateTime.utc_now(), 3, :day),
    status: "scheduled",
    created_by_id: giuseppe.id,
    is_private: true,
    base_capacity: 5,
    show_available_spots: false,
    show_partecipant_list: false
  })

# Create a free upcoming event
{:ok, free_event} =
  Occurences.create_occurence(%{
    title: "Community Open Mic",
    description: "Free open mic night for everyone!",
    location: "Parco Sempione",
    date: DateTime.add(DateTime.utc_now(), 14, :day),
    cost: nil,
    base_capacity: 30,
    status: "scheduled",
    created_by_id: danilo.id,
    is_private: false,
    show_available_spots: true,
    show_partecipant_list: false
  })

IO.puts("Adding coorganizers...")

# Add Giuseppe as coorganizer to Jam al BAM (automatically accepted since user exists)
{:ok, _coorg} = Occurences.invite_coorganizer(jam_bam.id, giuseppe.email, danilo)

IO.puts("Adding participants...")

# Register Giuseppe to the free event
{:ok, _participant1} =
  Occurences.register_participant(%{
    occurence_id: free_event.id,
    user_id: giuseppe.id,
    status: "confirmed",
    role: "base",
    nickname: "Giuseppe"
  })

# Register Maria to the free event
{:ok, _participant2} =
  Occurences.register_participant(%{
    occurence_id: free_event.id,
    user_id: maria.id,
    status: "confirmed",
    role: "flyer",
    nickname: "Maria"
  })

IO.puts("""

Seeds completed successfully!

Created users:
- danilo@example.com (password: password123456)
- giuseppe@example.com (password: password123456)
- maria@example.com (password: password123456)

Created #{Repo.aggregate(Occurences.Occurence, :count)} events
- Past events: 2
- Upcoming events: 4 (including 1 private)

You can now login with any of the above credentials!
""")
