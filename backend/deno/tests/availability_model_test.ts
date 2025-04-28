import { assertEquals, assertThrows } from "https://deno.land/std@0.181.0/testing/asserts.ts";
import { Availability } from "../models/availability.ts";

// Test 1 : Création d'une disponibilité simple valide
Deno.test("Création disponibilité simple valide", () => {
  const a = new Availability({
    professional_id: "pro-1",
    start_time: "2025-04-28T09:00:00Z",
    end_time: "2025-04-28T12:00:00Z"
  });
  assertEquals(a.professional_id, "pro-1");
  assertEquals(a.start_time, "2025-04-28T09:00:00Z");
  assertEquals(a.end_time, "2025-04-28T12:00:00Z");
  console.log("✅ Création disponibilité simple valide OK");
});

// Test 2 : Création avec end_time < start_time
Deno.test("Erreur end_time < start_time", () => {
  assertThrows(
    () => new Availability({
      professional_id: "pro-1",
      start_time: "2025-04-28T13:00:00Z",
      end_time: "2025-04-28T12:00:00Z"
    }),
    Error,
    "L'heure de fin doit être postérieure à l'heure de début."
  );
  console.log("✅ Erreur end_time < start_time détectée");
});

// Test 3 : Création disponibilité récurrente
Deno.test("Création disponibilité récurrente", () => {
  const a = new Availability({
    professional_id: "pro-2",
    day_of_week: 1, // lundi
    start_time: "09:00",
    end_time: "12:00",
    recurrence: "weekly"
  });
  assertEquals(a.day_of_week, 1);
  assertEquals(a.recurrence, "weekly");
  console.log("✅ Création disponibilité récurrente OK");
});

// Test 4 : professional_id manquant
Deno.test("Erreur professional_id manquant", () => {
  assertThrows(
    () => new Availability({
      start_time: "2025-04-28T09:00:00Z",
      end_time: "2025-04-28T12:00:00Z"
    }),
    Error,
    "Le professionnel est obligatoire."
  );
  console.log("✅ Erreur professional_id manquant détectée");
});

// Test 5 : Création avec chevauchement (simulation)
Deno.test("Erreur chevauchement de créneau (simulation)", () => {
  // Suppose qu'on a déjà un créneau de 9h à 12h
  const existing = [
    new Availability({ professional_id: "pro-1", start_time: "2025-04-28T09:00:00Z", end_time: "2025-04-28T12:00:00Z" })
  ];
  function tryAddOverlap() {
    // Nouveau créneau qui chevauche 10h-11h
    const newA = new Availability({ professional_id: "pro-1", start_time: "2025-04-28T10:00:00Z", end_time: "2025-04-28T11:00:00Z" });
    // Simulation de vérification
    for (const e of existing) {
      if (e.professional_id === newA.professional_id &&
          !(newA.end_time <= e.start_time || newA.start_time >= e.end_time)) {
        throw new Error("Créneau en conflit");
      }
    }
  }
  assertThrows(tryAddOverlap, Error, "Créneau en conflit");
  console.log("✅ Erreur chevauchement détectée");
});
