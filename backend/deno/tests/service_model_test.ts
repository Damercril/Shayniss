import { assertEquals, assertThrows } from "https://deno.land/std@0.181.0/testing/asserts.ts";
import { Service } from "../models/service.ts";

// Test 1 : Création d’un service valide
Deno.test("Service valide - création ok", () => {
  const s = new Service({
    name: "Massage relaxant",
    professional_id: "pro-id-1",
    price: 50,
    duration_minutes: 60,
    is_active: true,
    booking_count: 0
  });
  console.log("Création service valide:", s);
  assertEquals(s.name, "Massage relaxant");
  assertEquals(s.price, 50);
});

// Test 2 : Nom vide
Deno.test("Service nom vide - erreur explicite", () => {
  assertThrows(
    () => new Service({
      name: "",
      professional_id: "pro-id-1",
      price: 50,
      duration_minutes: 60,
      is_active: true,
      booking_count: 0
    }),
    Error,
    "Le nom du service ne peut pas être vide."
  );
});

// Test 3 : Prix négatif
Deno.test("Service prix négatif - erreur explicite", () => {
  assertThrows(
    () => new Service({
      name: "Massage",
      professional_id: "pro-id-1",
      price: -10,
      duration_minutes: 60,
      is_active: true,
      booking_count: 0
    }),
    Error,
    "Le prix doit être positif ou nul."
  );
});

// Test 4 : Durée négative
Deno.test("Service durée négative - erreur explicite", () => {
  assertThrows(
    () => new Service({
      name: "Massage",
      professional_id: "pro-id-1",
      price: 50,
      duration_minutes: -5,
      is_active: true,
      booking_count: 0
    }),
    Error,
    "La durée doit être positive ou nulle."
  );
});

// Test 5 : booking_count négatif
Deno.test("Service booking_count négatif - erreur explicite", () => {
  assertThrows(
    () => new Service({
      name: "Massage",
      professional_id: "pro-id-1",
      price: 50,
      duration_minutes: 60,
      is_active: true,
      booking_count: -1
    }),
    Error,
    "Le nombre de réservations doit être positif ou nul."
  );
});
