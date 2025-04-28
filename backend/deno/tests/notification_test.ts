import { assertEquals } from "https://deno.land/std@0.181.0/testing/asserts.ts";

// Test 1 : Notification au client lors de la création d'une réservation
Deno.test("Notification client à la création réservation", async () => {
  const availRes = await fetch("http://localhost:8000/availabilities", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      professional_id: "pro-notif-1",
      start_time: "2025-08-01T10:00:00Z",
      end_time: "2025-08-01T11:00:00Z"
    })
  });
  const avail = await availRes.json();
  await fetch("http://localhost:8000/bookings", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      client_id: "client-notif-1",
      availability_id: avail.id,
      booking_date: "2025-08-01T10:00:00Z"
    })
  });
  // Vérifier notification client
  const notifRes = await fetch("http://localhost:8000/notifications?user_id=client-notif-1");
  const notifications = await notifRes.json();
  const found = notifications.some((n: any) => n.type === "booking_created");
  console.log("Notification client création:", found, notifications);
  assertEquals(found, true);
});

// Test 2 : Notification professionnel à la création d'une réservation
Deno.test("Notification pro à la création réservation", async () => {
  const availRes = await fetch("http://localhost:8000/availabilities", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      professional_id: "pro-notif-2",
      start_time: "2025-08-02T10:00:00Z",
      end_time: "2025-08-02T11:00:00Z"
    })
  });
  const avail = await availRes.json();
  await fetch("http://localhost:8000/bookings", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      client_id: "client-notif-2",
      availability_id: avail.id,
      booking_date: "2025-08-02T10:00:00Z"
    })
  });
  // Vérifier notification pro
  const notifRes = await fetch("http://localhost:8000/notifications?user_id=pro-notif-2");
  const notifications = await notifRes.json();
  const found = notifications.some((n: any) => n.type === "booking_new_client");
  console.log("Notification pro création:", found, notifications);
  assertEquals(found, true);
});

// Test 3 : Notification lors de l'annulation d'une réservation
Deno.test("Notification annulation réservation", async () => {
  const availRes = await fetch("http://localhost:8000/availabilities", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      professional_id: "pro-notif-3",
      start_time: "2025-08-03T10:00:00Z",
      end_time: "2025-08-03T11:00:00Z"
    })
  });
  const avail = await availRes.json();
  const bookRes = await fetch("http://localhost:8000/bookings", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      client_id: "client-notif-3",
      availability_id: avail.id,
      booking_date: "2025-08-03T10:00:00Z"
    })
  });
  const booking = await bookRes.json();
  await fetch(`http://localhost:8000/bookings/${booking.id}`, { method: "DELETE" });
  // Vérifier notification client et pro
  const notifClient = await (await fetch("http://localhost:8000/notifications?user_id=client-notif-3")).json();
  const notifPro = await (await fetch("http://localhost:8000/notifications?user_id=pro-notif-3")).json();
  const foundClient = notifClient.some((n: any) => n.type === "booking_cancelled");
  const foundPro = notifPro.some((n: any) => n.type === "booking_cancelled");
  console.log("Notification annulation client:", foundClient, notifClient);
  console.log("Notification annulation pro:", foundPro, notifPro);
  assertEquals(foundClient, true);
  assertEquals(foundPro, true);
});

// Test 4 : Robustesse (pas de notification si échec)
Deno.test("Pas de notification si échec réservation", async () => {
  // Tentative de réservation sur créneau inexistant
  await fetch("http://localhost:8000/bookings", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      client_id: "client-notif-4",
      availability_id: "id-inexistant",
      booking_date: "2025-08-04T10:00:00Z"
    })
  });
  // Vérifier qu'il n'y a pas de notification créée
  const notifRes = await fetch("http://localhost:8000/notifications?user_id=client-notif-4");
  const notifications = await notifRes.json();
  const found = notifications.some((n: any) => n.type === "booking_created");
  console.log("Notification client échec:", found, notifications);
  assertEquals(found, false);
});
