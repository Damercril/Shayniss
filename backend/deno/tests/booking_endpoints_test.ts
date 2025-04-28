import { assertEquals } from "https://deno.land/std@0.181.0/testing/asserts.ts";

// Test 1 : Consultation des réservations par client
Deno.test("GET /bookings?client_id=...", async () => {
  // Création d'une réservation
  const availRes = await fetch("http://localhost:8000/availabilities", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      professional_id: "pro-endpoint-1",
      start_time: "2025-06-10T09:00:00Z",
      end_time: "2025-06-10T10:00:00Z"
    })
  });
  const avail = await availRes.json();
  await fetch("http://localhost:8000/bookings", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      client_id: "client-endpoint-1",
      availability_id: avail.id,
      booking_date: "2025-06-10T09:00:00Z"
    })
  });
  // Consultation par client
  const res = await fetch(`http://localhost:8000/bookings?client_id=client-endpoint-1`);
  const bookings = await res.json();
  console.log("Consultation réservations client:", res.status, bookings);
  assertEquals(res.status, 200);
  for (const b of bookings) {
    assertEquals(b.client_id, "client-endpoint-1");
  }
});

// Test 2 : Consultation d'une réservation par id
Deno.test("GET /bookings/:id - succès", async () => {
  // Création d'une réservation
  const availRes = await fetch("http://localhost:8000/availabilities", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      professional_id: "pro-endpoint-2",
      start_time: "2025-06-11T09:00:00Z",
      end_time: "2025-06-11T10:00:00Z"
    })
  });
  const avail = await availRes.json();
  const bookRes = await fetch("http://localhost:8000/bookings", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      client_id: "client-endpoint-2",
      availability_id: avail.id,
      booking_date: "2025-06-11T09:00:00Z"
    })
  });
  const booking = await bookRes.json();
  // Consultation par id
  const res = await fetch(`http://localhost:8000/bookings/${booking.id}`);
  const b = await res.json();
  console.log("Consultation réservation par id:", res.status, b);
  assertEquals(res.status, 200);
  assertEquals(b.id, booking.id);
});

// Test 3 : Consultation d'une réservation inexistante
Deno.test("GET /bookings/:id - not found", async () => {
  const res = await fetch("http://localhost:8000/bookings/id-inexistant");
  const body = await res.json();
  console.log("Consultation réservation inexistante:", res.status, body);
  assertEquals(res.status, 404);
  assertEquals(body.error, "Réservation non trouvée");
});

// Test 4 : Annulation avancée (statut non annulable)
Deno.test("DELETE /bookings/:id - déjà annulée", async () => {
  // Création d'une réservation
  const availRes = await fetch("http://localhost:8000/availabilities", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      professional_id: "pro-endpoint-3",
      start_time: "2025-06-12T09:00:00Z",
      end_time: "2025-06-12T10:00:00Z"
    })
  });
  const avail = await availRes.json();
  const bookRes = await fetch("http://localhost:8000/bookings", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      client_id: "client-endpoint-3",
      availability_id: avail.id,
      booking_date: "2025-06-12T09:00:00Z"
    })
  });
  const booking = await bookRes.json();
  // Annulation une première fois
  await fetch(`http://localhost:8000/bookings/${booking.id}`, { method: "DELETE" });
  // Tentative d'annulation à nouveau
  const res = await fetch(`http://localhost:8000/bookings/${booking.id}`, { method: "DELETE" });
  const body = await res.json();
  console.log("Annulation déjà annulée:", res.status, body);
  assertEquals(res.status, 400);
  assertEquals(body.error, "Réservation déjà annulée");
});

// Test 5 : Robustesse (erreur requête mal formée)
Deno.test("POST /bookings - requête mal formée", async () => {
  const res = await fetch("http://localhost:8000/bookings", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({}) // champs manquants
  });
  const body = await res.json();
  console.log("Erreur requête mal formée:", res.status, body);
  assertEquals(res.status, 400);
});
