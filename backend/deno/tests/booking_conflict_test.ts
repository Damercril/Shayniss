import { assertEquals } from "https://deno.land/std@0.181.0/testing/asserts.ts";

// Test 1 : Réservation sur créneau déjà réservé (conflit)
Deno.test("POST /bookings - créneau déjà réservé (conflit)", async () => {
  // Création d'un créneau
  const availRes = await fetch("http://localhost:8000/availabilities", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      professional_id: "pro-conflit-1",
      start_time: "2025-07-01T10:00:00Z",
      end_time: "2025-07-01T11:00:00Z"
    })
  });
  const avail = await availRes.json();
  // Première réservation
  await fetch("http://localhost:8000/bookings", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      client_id: "client-conflit-1",
      availability_id: avail.id,
      booking_date: "2025-07-01T10:00:00Z"
    })
  });
  // Tentative de réservation sur le même créneau
  const res = await fetch("http://localhost:8000/bookings", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      client_id: "client-conflit-2",
      availability_id: avail.id,
      booking_date: "2025-07-01T10:00:00Z"
    })
  });
  const body = await res.json();
  console.log("Conflit créneau déjà réservé:", res.status, body);
  assertEquals(res.status, 400);
  assertEquals(body.error, "Créneau déjà réservé");
});

// Test 2 : Réservation qui chevauche une autre réservation du même client
Deno.test("POST /bookings - chevauchement réservation client", async () => {
  // Création de deux créneaux qui se chevauchent
  const avail1 = await (await fetch("http://localhost:8000/availabilities", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      professional_id: "pro-conflit-2",
      start_time: "2025-07-02T10:00:00Z",
      end_time: "2025-07-02T11:00:00Z"
    })
  })).json();
  const avail2 = await (await fetch("http://localhost:8000/availabilities", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      professional_id: "pro-conflit-2",
      start_time: "2025-07-02T10:30:00Z",
      end_time: "2025-07-02T11:30:00Z"
    })
  })).json();
  // Première réservation
  await fetch("http://localhost:8000/bookings", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      client_id: "client-conflit-3",
      availability_id: avail1.id,
      booking_date: "2025-07-02T10:00:00Z"
    })
  });
  // Tentative de réservation qui se chevauche
  const res = await fetch("http://localhost:8000/bookings", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      client_id: "client-conflit-3",
      availability_id: avail2.id,
      booking_date: "2025-07-02T10:30:00Z"
    })
  });
  const body = await res.json();
  console.log("Conflit chevauchement client:", res.status, body);
  assertEquals(res.status, 400);
  assertEquals(body.error, "Conflit avec une autre réservation du client");
});

// Test 3 : Validation stricte des horaires
Deno.test("POST /bookings - horaires invalides", async () => {
  // Créneau avec heure de fin < heure de début
  const res = await fetch("http://localhost:8000/availabilities", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      professional_id: "pro-conflit-3",
      start_time: "2025-07-03T12:00:00Z",
      end_time: "2025-07-03T11:00:00Z"
    })
  });
  const body = await res.json();
  console.log("Créneau horaires invalides:", res.status, body);
  assertEquals(res.status, 400);
});

// Test 4 : Robustesse (requête mal formée)
Deno.test("POST /bookings - données mal formées", async () => {
  const res = await fetch("http://localhost:8000/bookings", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({})
  });
  const body = await res.json();
  console.log("Erreur requête mal formée:", res.status, body);
  assertEquals(res.status, 400);
});
