import { assertEquals } from "https://deno.land/std@0.181.0/testing/asserts.ts";

// Test 1 : Création d'une réservation sur créneau libre
Deno.test("POST /bookings - succès", async () => {
  // Création d'un créneau disponible
  const availRes = await fetch("http://localhost:8000/availabilities", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      professional_id: "pro-booking-1",
      start_time: "2025-06-01T09:00:00Z",
      end_time: "2025-06-01T10:00:00Z"
    })
  });
  const avail = await availRes.json();
  // Création d'une réservation
  const res = await fetch("http://localhost:8000/bookings", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      client_id: "client-1",
      availability_id: avail.id,
      booking_date: "2025-06-01T09:00:00Z"
    })
  });
  const booking = await res.json();
  console.log("Création réservation:", res.status, booking);
  assertEquals(res.status, 201);
  assertEquals(booking.availability_id, avail.id);
});

// Test 2 : Création réservation sur créneau déjà réservé
Deno.test("POST /bookings - créneau déjà réservé", async () => {
  // Création d'un créneau
  const availRes = await fetch("http://localhost:8000/availabilities", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      professional_id: "pro-booking-2",
      start_time: "2025-06-02T09:00:00Z",
      end_time: "2025-06-02T10:00:00Z"
    })
  });
  const avail = await availRes.json();
  // Première réservation
  await fetch("http://localhost:8000/bookings", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      client_id: "client-2",
      availability_id: avail.id,
      booking_date: "2025-06-02T09:00:00Z"
    })
  });
  // Tentative de double réservation
  const res = await fetch("http://localhost:8000/bookings", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      client_id: "client-3",
      availability_id: avail.id,
      booking_date: "2025-06-02T09:00:00Z"
    })
  });
  const body = await res.json();
  console.log("Erreur double réservation:", res.status, body);
  assertEquals(res.status, 400);
  assertEquals(body.error, "Créneau déjà réservé");
});

// Test 3 : Création réservation sur créneau avec exception
Deno.test("POST /bookings - créneau indisponible (exception)", async () => {
  // Création d'un créneau
  const availRes = await fetch("http://localhost:8000/availabilities", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      professional_id: "pro-booking-3",
      start_time: "2025-06-03T09:00:00Z",
      end_time: "2025-06-03T10:00:00Z"
    })
  });
  const avail = await availRes.json();
  // Création d'une exception
  await fetch("http://localhost:8000/availability_exceptions", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      availability_id: avail.id,
      exception_date: "2025-06-03"
    })
  });
  // Tentative de réservation sur la date exclue
  const res = await fetch("http://localhost:8000/bookings", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      client_id: "client-4",
      availability_id: avail.id,
      booking_date: "2025-06-03T09:00:00Z"
    })
  });
  const body = await res.json();
  console.log("Erreur créneau indisponible (exception):", res.status, body);
  assertEquals(res.status, 400);
  assertEquals(body.error, "Créneau indisponible à cette date");
});

// Test 4 : Consultation des réservations d'un professionnel
Deno.test("GET /bookings?professional_id=...", async () => {
  // Création d'un créneau et d'une réservation
  const availRes = await fetch("http://localhost:8000/availabilities", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      professional_id: "pro-booking-4",
      start_time: "2025-06-04T09:00:00Z",
      end_time: "2025-06-04T10:00:00Z"
    })
  });
  const avail = await availRes.json();
  await fetch("http://localhost:8000/bookings", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      client_id: "client-5",
      availability_id: avail.id,
      booking_date: "2025-06-04T09:00:00Z"
    })
  });
  // Consultation
  const res = await fetch(`http://localhost:8000/bookings?professional_id=pro-booking-4`);
  const bookings = await res.json();
  console.log("Consultation réservations pro:", res.status, bookings);
  assertEquals(res.status, 200);
  for (const b of bookings) {
    assertEquals(b.professional_id, "pro-booking-4");
  }
});

// Test 5 : Annulation d'une réservation
Deno.test("DELETE /bookings/:id", async () => {
  // Création d'un créneau et d'une réservation
  const availRes = await fetch("http://localhost:8000/availabilities", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      professional_id: "pro-booking-5",
      start_time: "2025-06-05T09:00:00Z",
      end_time: "2025-06-05T10:00:00Z"
    })
  });
  const avail = await availRes.json();
  const bookRes = await fetch("http://localhost:8000/bookings", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      client_id: "client-6",
      availability_id: avail.id,
      booking_date: "2025-06-05T09:00:00Z"
    })
  });
  const booking = await bookRes.json();
  // Annulation
  const res = await fetch(`http://localhost:8000/bookings/${booking.id}`, {
    method: "DELETE"
  });
  console.log("Annulation réservation:", res.status);
  assertEquals(res.status, 204);
});

// Test 6 : Conflit de réservation (double réservation, statut non annulable)
Deno.test("POST /bookings - conflit statut", async () => {
  // Création d'un créneau et d'une réservation
  const availRes = await fetch("http://localhost:8000/availabilities", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      professional_id: "pro-booking-6",
      start_time: "2025-06-06T09:00:00Z",
      end_time: "2025-06-06T10:00:00Z"
    })
  });
  const avail = await availRes.json();
  const bookRes = await fetch("http://localhost:8000/bookings", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      client_id: "client-7",
      availability_id: avail.id,
      booking_date: "2025-06-06T09:00:00Z"
    })
  });
  const booking = await bookRes.json();
  // Tentative de double réservation (statut déjà réservé)
  const res = await fetch("http://localhost:8000/bookings", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      client_id: "client-8",
      availability_id: avail.id,
      booking_date: "2025-06-06T09:00:00Z"
    })
  });
  const body = await res.json();
  console.log("Erreur conflit statut réservation:", res.status, body);
  assertEquals(res.status, 400);
  assertEquals(body.error, "Créneau déjà réservé");
});
