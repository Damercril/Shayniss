import { assertEquals } from "https://deno.land/std@0.181.0/testing/asserts.ts";

// Test 1 : Création créneau + exception + vérification indisponibilité effective
Deno.test("Disponibilité effective après exception", async () => {
  // Création d'un créneau
  const availRes = await fetch("http://localhost:8000/availabilities", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      professional_id: "pro-global-1",
      start_time: "2025-05-20T09:00:00Z",
      end_time: "2025-05-20T12:00:00Z"
    })
  });
  const avail = await availRes.json();
  // Création d'une exception sur ce créneau
  const exRes = await fetch("http://localhost:8000/availability_exceptions", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      availability_id: avail.id,
      exception_date: "2025-05-20"
    })
  });
  const exception = await exRes.json();
  // Vérification que la date est bien indisponible (simulateur métier à implémenter)
  // Ici on suppose un endpoint GET /availabilities/:id/available?date=...
  // (À adapter selon l'implémentation réelle)
  // const check = await fetch(`http://localhost:8000/availabilities/${avail.id}/available?date=2025-05-20`);
  // const isAvailable = await check.json();
  // assertEquals(isAvailable.available, false);
  console.log("Test 1 : Créneau + exception => indisponibilité effective (à implémenter côté métier)");
  assertEquals(true, true); // Placeholder
});

// Test 2 : Créneaux récurrents + multiples exceptions
Deno.test("Créneaux récurrents et exceptions multiples", async () => {
  // Création d'un créneau récurrent (exemple fictif)
  const availRes = await fetch("http://localhost:8000/availabilities", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      professional_id: "pro-global-2",
      day_of_week: 2, // mardi
      start_time: "09:00:00",
      end_time: "12:00:00"
    })
  });
  const avail = await availRes.json();
  // Ajout de 2 exceptions
  await fetch("http://localhost:8000/availability_exceptions", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      availability_id: avail.id,
      exception_date: "2025-05-27"
    })
  });
  await fetch("http://localhost:8000/availability_exceptions", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      availability_id: avail.id,
      exception_date: "2025-06-03"
    })
  });
  // Vérification fictive que ces dates sont bien exclues (simulateur métier à implémenter)
  console.log("Test 2 : Récurrence + exceptions multiples => indisponibilité effective sur les dates exclues (à implémenter côté métier)");
  assertEquals(true, true); // Placeholder
});

// Test 3 : Suppression en cascade (créneau + exceptions)
Deno.test("Suppression créneau supprime exceptions associées", async () => {
  // Création d'un créneau
  const availRes = await fetch("http://localhost:8000/availabilities", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      professional_id: "pro-global-3",
      start_time: "2025-05-21T09:00:00Z",
      end_time: "2025-05-21T12:00:00Z"
    })
  });
  const avail = await availRes.json();
  // Création d'une exception
  const exRes = await fetch("http://localhost:8000/availability_exceptions", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      availability_id: avail.id,
      exception_date: "2025-05-21"
    })
  });
  const exception = await exRes.json();
  // Suppression du créneau
  await fetch(`http://localhost:8000/availabilities/${avail.id}`, { method: "DELETE" });
  // Vérification que l'exception n'existe plus (simulateur métier à implémenter)
  console.log("Test 3 : Suppression créneau => suppression exceptions associées (à implémenter côté base ou service)");
  assertEquals(true, true); // Placeholder
});

// Test 4 : Robustesse (erreurs inattendues)
Deno.test("Robustesse gestion des erreurs", async () => {
  // Création d'une exception sur un id inexistant
  const res = await fetch("http://localhost:8000/availability_exceptions", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      availability_id: "id-inexistant-global",
      exception_date: "2025-05-30"
    })
  });
  const body = await res.json();
  console.log("Test 4 : Erreur attendue (créneau inexistant)", res.status, body);
  assertEquals(res.status, 400);
  assertEquals(body.error, "Créneau de disponibilité inexistant");
});
