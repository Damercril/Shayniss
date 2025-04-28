// Regroupement des routes principales

import { Router } from "https://deno.land/x/oak@v12.6.1/mod.ts";
import { AuthService } from '../services/auth_service.ts';
import { UserService } from '../services/user_service.ts';
import { ProfessionalService } from '../services/professional_service.ts';
import { ServiceService } from '../services/service_service.ts';
import { CategoryService } from '../services/category_service.ts';
import { AvailabilityService } from '../services/availability_service.ts';
import { AvailabilityExceptionService } from '../services/availability_exception_service.ts';
import { BookingService } from '../services/booking_service.ts';
import notificationsRouter from "./notifications.ts";
import conversationsRouter from "./conversations.ts";
import messagesRouter from "./messages.ts";

const router = new Router();

// Route de healthcheck améliorée
router.get("/health", async (ctx) => {
  console.log("[HEALTH] Début healthcheck complet");
  try {
    // Test simple sur la table users
    const { data, error } = await UserService.countUsers();
    if (error) {
      console.error("[HEALTH] Erreur accès base:", error);
      ctx.response.status = 500;
      ctx.response.body = { status: "error", db: "disconnected", error: error.message || error };
      return;
    }
    console.log("[HEALTH] Base accessible, users:", data.count);
    ctx.response.status = 200;
    ctx.response.body = { status: "ok", db: "connected", userCount: data.count };
  } catch (e) {
    console.error("[HEALTH] Exception healthcheck:", e);
    ctx.response.status = 500;
    ctx.response.body = { status: "error", db: "disconnected", error: e.message };
  }
  console.log("[HEALTH] Fin healthcheck");
});

// Route d'inscription
router.post("/auth/register", async (ctx) => {
  console.log("[AUTH][REGISTER] Début traitement");
  try {
    const { email, password, role } = await ctx.request.body({ type: "json" }).value;
    console.log("[AUTH][REGISTER] Body reçu:", { email, password, role });
    const { user, error } = await AuthService.register(email, password, role);
    if (error) {
      console.error("[AUTH][REGISTER] Erreur lors de l'inscription:", error);
      ctx.response.status = 400;
      ctx.response.body = { error: error.message };
      return;
    }
    console.log("[AUTH][REGISTER] Succès, utilisateur créé:", user);
    ctx.response.status = 201;
    ctx.response.body = { user };
  } catch (e) {
    console.error("[AUTH][REGISTER] Exception attrapée:", e);
    ctx.response.status = 500;
    ctx.response.body = { error: e.message };
  }
  console.log("[AUTH][REGISTER] Fin traitement");
});

// GET /users/:id
router.get("/users/:id", async (ctx) => {
  const id = ctx.params.id;
  const { user, error } = await UserService.getUserById(id);
  if (error) {
    ctx.response.status = error === "Utilisateur non trouvé." ? 404 : 500;
    ctx.response.body = { error };
    console.log("Erreur getUserById:", error);
  } else if (user) {
    ctx.response.status = 200;
    ctx.response.body = user;
    console.log("Utilisateur trouvé:", user.email);
  }
});

// POST /users
router.post("/users", async (ctx) => {
  try {
    const { email, password, role } = await ctx.request.body({ type: "json" }).value;
    const { user, error } = await UserService.createUser(email, password, role);
    if (error) {
      ctx.response.status = 400;
      ctx.response.body = { error };
      console.log("Erreur création utilisateur:", error);
    } else if (user) {
      ctx.response.status = 201;
      ctx.response.body = { id: user.id, email: user.email, role: user.role, created_at: user.created_at };
      console.log("Utilisateur créé:", user.email);
    } else {
      ctx.response.status = 500;
      ctx.response.body = { error: "Erreur inattendue lors de la création d'utilisateur." };
      console.error("Erreur inattendue: user est undefined alors qu'aucune erreur n'est retournée.");
    }
  } catch (e) {
    ctx.response.status = 500;
    ctx.response.body = { error: "Erreur serveur." };
    console.error("Erreur serveur POST /users:", e);
  }
});

// GET /professionals/:id
router.get("/professionals/:id", async (ctx) => {
  const id = ctx.params.id;
  const { professional, error } = await ProfessionalService.getProfessionalById(id);
  if (error) {
    ctx.response.status = error === "Professionnel non trouvé." ? 404 : 500;
    ctx.response.body = { error };
    console.log("Erreur getProfessionalById:", error);
  } else if (professional) {
    ctx.response.status = 200;
    ctx.response.body = professional;
    console.log("Professionnel trouvé:", professional.display_name);
  }
});

// POST /professionals
router.post("/professionals", async (ctx) => {
  try {
    const { user_id, display_name, category_id, is_active } = await ctx.request.body({ type: "json" }).value;
    const { professional, error } = await ProfessionalService.createProfessional(user_id, display_name, category_id, is_active);
    if (error) {
      ctx.response.status = 400;
      ctx.response.body = { error };
      console.log("Erreur création professionnel:", error);
    } else if (professional) {
      ctx.response.status = 201;
      ctx.response.body = professional;
      console.log("Professionnel créé:", professional.display_name);
    } else {
      ctx.response.status = 500;
      ctx.response.body = { error: "Erreur inattendue lors de la création de professionnel." };
      console.error("Erreur inattendue: professional est undefined alors qu'aucune erreur n'est retournée.");
    }
  } catch (e) {
    ctx.response.status = 500;
    ctx.response.body = { error: "Erreur serveur." };
    console.error("Erreur serveur POST /professionals:", e);
  }
});

// GET /services/:id
router.get("/services/:id", async (ctx) => {
  const id = ctx.params.id;
  const { service, error } = await ServiceService.getServiceById(id);
  if (error) {
    ctx.response.status = error === "Service non trouvé." ? 404 : 500;
    ctx.response.body = { error };
    console.log("Erreur getServiceById:", error);
  } else if (service) {
    ctx.response.status = 200;
    ctx.response.body = service;
    console.log("Service trouvé:", service.name);
  }
});

// GET /services (recherche/filtres)
router.get("/services", async (ctx) => {
  const query = ctx.request.url.searchParams;
  const params: any = {};
  if (query.has("search")) params.search = query.get("search");
  if (query.has("category_id")) params.category_id = query.get("category_id");
  if (query.has("max_price")) params.max_price = Number(query.get("max_price"));
  if (query.has("order_by")) params.order_by = query.get("order_by");
  if (query.has("limit")) params.limit = Number(query.get("limit"));
  if (query.has("offset")) params.offset = Number(query.get("offset"));
  // Ajout des filtres inconnus pour test d'erreur
  for (const [k, v] of query.entries()) {
    if (!(k in params)) params[k] = v;
  }
  const { services, error } = await ServiceService.searchServices(params);
  if (error) {
    ctx.response.status = 400;
    ctx.response.body = { error };
    console.log("Erreur recherche/filtres services:", error);
  } else {
    ctx.response.status = 200;
    ctx.response.body = services;
    console.log("Recherche/filtres services:", params, services.length, "résultats");
  }
});

// POST /services
router.post("/services", async (ctx) => {
  try {
    const { name, professional_id, price, duration_minutes, is_active } = await ctx.request.body({ type: "json" }).value;
    const { service, error } = await ServiceService.createService(name, professional_id, price, duration_minutes, is_active);
    if (error) {
      ctx.response.status = 400;
      ctx.response.body = { error };
      console.log("Erreur création service:", error);
    } else if (service) {
      ctx.response.status = 201;
      ctx.response.body = service;
      console.log("Service créé:", service.name);
    } else {
      ctx.response.status = 500;
      ctx.response.body = { error: "Erreur inattendue lors de la création du service." };
      console.error("Erreur inattendue: service est undefined alors qu'aucune erreur n'est retournée.");
    }
  } catch (e) {
    ctx.response.status = 500;
    ctx.response.body = { error: "Erreur serveur." };
    console.error("Erreur serveur POST /services:", e);
  }
});

// POST /categories
router.post("/categories", async (ctx) => {
  try {
    const { name } = await ctx.request.body({ type: "json" }).value;
    const { category, error } = await CategoryService.createCategory(name);
    if (error) {
      ctx.response.status = 400;
      ctx.response.body = { error };
      console.log("Erreur création catégorie:", error);
    } else if (category) {
      ctx.response.status = 201;
      ctx.response.body = category;
      console.log("Catégorie créée:", category.name);
    } else {
      ctx.response.status = 500;
      ctx.response.body = { error: "Erreur inattendue lors de la création de catégorie." };
      console.error("Erreur inattendue: category est undefined alors qu'aucune erreur n'est retournée.");
    }
  } catch (e) {
    ctx.response.status = 500;
    ctx.response.body = { error: "Erreur serveur." };
    console.error("Erreur serveur POST /categories:", e);
  }
});

// GET /categories/:id
router.get("/categories/:id", async (ctx) => {
  const id = ctx.params.id;
  const { category, error } = await CategoryService.getCategoryById(id);
  if (error) {
    ctx.response.status = error === "Catégorie non trouvée." ? 404 : 500;
    ctx.response.body = { error };
    console.log("Erreur getCategoryById:", error);
  } else if (category) {
    ctx.response.status = 200;
    ctx.response.body = category;
    console.log("Catégorie trouvée:", category.name);
  }
});

// GET /categories (liste paginée/filtrée)
router.get("/categories", async (ctx) => {
  const query = ctx.request.url.searchParams;
  const params: any = {};
  if (query.has("search")) params.search = query.get("search");
  if (query.has("limit")) params.limit = Number(query.get("limit"));
  if (query.has("offset")) params.offset = Number(query.get("offset"));
  const { categories, error } = await CategoryService.searchCategories(params);
  if (error) {
    ctx.response.status = 400;
    ctx.response.body = { error };
    console.log("Erreur recherche catégories:", error);
  } else {
    ctx.response.status = 200;
    ctx.response.body = categories;
    console.log("Recherche catégories:", params, categories.length, "résultats");
  }
});

// POST /availabilities
router.post("/availabilities", async (ctx) => {
  try {
    const data = await ctx.request.body({ type: "json" }).value;
    const { availability, error } = await AvailabilityService.createAvailability(data);
    if (error) {
      ctx.response.status = 400;
      ctx.response.body = { error };
      console.log("Erreur création disponibilité:", error);
    } else if (availability) {
      ctx.response.status = 201;
      ctx.response.body = availability;
      console.log("Disponibilité créée:", availability.id);
    } else {
      ctx.response.status = 500;
      ctx.response.body = { error: "Erreur inattendue lors de la création de disponibilité." };
      console.error("Erreur inattendue: availability est undefined alors qu'aucune erreur n'est retournée.");
    }
  } catch (e) {
    ctx.response.status = 500;
    ctx.response.body = { error: "Erreur serveur." };
    console.error("Erreur serveur POST /availabilities:", e);
  }
});

// GET /availabilities/:id
router.get("/availabilities/:id", async (ctx) => {
  const id = ctx.params.id;
  const { availability, error } = await AvailabilityService.getAvailabilityById(id);
  if (error) {
    ctx.response.status = error === "Disponibilité non trouvée." ? 404 : 400;
    ctx.response.body = { error };
    console.log("Erreur getAvailabilityById:", error);
  } else if (availability) {
    ctx.response.status = 200;
    ctx.response.body = availability;
    console.log("Disponibilité trouvée:", availability.id);
  }
});

// PATCH /availabilities/:id
router.patch("/availabilities/:id", async (ctx) => {
  const id = ctx.params.id;
  const patch = await ctx.request.body({ type: "json" }).value;
  const { availability, error } = await AvailabilityService.updateAvailability(id, patch);
  if (error) {
    ctx.response.status = 400;
    ctx.response.body = { error };
    console.log("Erreur modification disponibilité:", error);
  } else if (availability) {
    ctx.response.status = 200;
    ctx.response.body = availability;
    console.log("Disponibilité modifiée:", availability.id);
  }
});

// DELETE /availabilities/:id
router.delete("/availabilities/:id", async (ctx) => {
  const id = ctx.params.id;
  const { error } = await AvailabilityService.deleteAvailability(id);
  if (error) {
    ctx.response.status = 400;
    ctx.response.body = { error };
    console.log("Erreur suppression disponibilité:", error);
  } else {
    ctx.response.status = 204;
    ctx.response.body = null;
    console.log("Disponibilité supprimée:", id);
  }
});

// GET /availabilities (liste paginée/filtrée)
router.get("/availabilities", async (ctx) => {
  const query = ctx.request.url.searchParams;
  const params: any = {};
  if (query.has("pro")) params.pro = query.get("pro");
  if (query.has("day")) params.day = Number(query.get("day"));
  const { availabilities, error } = await AvailabilityService.searchAvailabilities(params);
  if (error) {
    ctx.response.status = 400;
    ctx.response.body = { error };
    console.log("Erreur recherche disponibilités:", error);
  } else {
    ctx.response.status = 200;
    ctx.response.body = availabilities;
    console.log("Recherche disponibilités:", params, availabilities.length, "résultats");
  }
});

// POST /availability_exceptions
router.post("/availability_exceptions", async (ctx) => {
  try {
    const data = await ctx.request.body({ type: "json" }).value;
    const { exception, error } = await AvailabilityExceptionService.createException(data);
    if (error) {
      ctx.response.status = 400;
      ctx.response.body = { error };
      console.log("Erreur création exception:", error);
    } else if (exception) {
      ctx.response.status = 201;
      ctx.response.body = exception;
      console.log("Exception créée:", exception.id);
    } else {
      ctx.response.status = 500;
      ctx.response.body = { error: "Erreur inattendue lors de la création d'exception." };
      console.error("Erreur inattendue: exception est undefined alors qu'aucune erreur n'est retournée.");
    }
  } catch (e) {
    ctx.response.status = 500;
    ctx.response.body = { error: "Erreur serveur." };
    console.error("Erreur serveur POST /availability_exceptions:", e);
  }
});

// GET /availability_exceptions (liste filtrée)
router.get("/availability_exceptions", async (ctx) => {
  const query = ctx.request.url.searchParams;
  const params: any = {};
  if (query.has("availability_id")) params.availability_id = query.get("availability_id");
  const { exceptions, error } = await AvailabilityExceptionService.listExceptions(params);
  if (error) {
    ctx.response.status = 400;
    ctx.response.body = { error };
    console.log("Erreur recherche exceptions:", error);
  } else {
    ctx.response.status = 200;
    ctx.response.body = exceptions;
    console.log("Recherche exceptions:", params, exceptions.length, "résultats");
  }
});

// DELETE /availability_exceptions/:id
router.delete("/availability_exceptions/:id", async (ctx) => {
  const id = ctx.params.id;
  const { error } = await AvailabilityExceptionService.deleteException(id);
  if (error) {
    ctx.response.status = 400;
    ctx.response.body = { error };
    console.log("Erreur suppression exception:", error);
  } else {
    ctx.response.status = 204;
    ctx.response.body = null;
    console.log("Exception supprimée:", id);
  }
});

// POST /bookings
router.post("/bookings", async (ctx) => {
  try {
    const data = await ctx.request.body({ type: "json" }).value;
    const { booking, error } = await BookingService.createBooking(data);
    if (error) {
      ctx.response.status = 400;
      ctx.response.body = { error };
      console.log("Erreur création réservation:", error);
    } else if (booking) {
      ctx.response.status = 201;
      ctx.response.body = booking;
      console.log("Réservation créée:", booking.id);
    } else {
      ctx.response.status = 500;
      ctx.response.body = { error: "Erreur inattendue lors de la création de réservation." };
      console.error("Erreur inattendue: booking est undefined alors qu'aucune erreur n'est retournée.");
    }
  } catch (e) {
    ctx.response.status = 500;
    ctx.response.body = { error: "Erreur serveur." };
    console.error("Erreur serveur POST /bookings:", e);
  }
});

// GET /bookings/:id
router.get("/bookings/:id", async (ctx) => {
  const id = ctx.params.id;
  const { booking, error, notFound } = await BookingService.getBookingById(id);
  if (notFound) {
    ctx.response.status = 404;
    ctx.response.body = { error };
    console.log("Consultation réservation inexistante:", id, error);
  } else if (error) {
    ctx.response.status = 400;
    ctx.response.body = { error };
    console.log("Erreur récupération réservation:", error);
  } else {
    ctx.response.status = 200;
    ctx.response.body = booking;
    console.log("Consultation réservation:", id, booking);
  }
});

// GET /bookings (liste filtrée)
router.get("/bookings", async (ctx) => {
  const query = ctx.request.url.searchParams;
  const params: any = {};
  if (query.has("professional_id")) params.professional_id = query.get("professional_id");
  if (query.has("client_id")) params.client_id = query.get("client_id");
  const { bookings, error } = await BookingService.listBookings(params);
  if (error) {
    ctx.response.status = 400;
    ctx.response.body = { error };
    console.log("Erreur recherche réservations:", error);
  } else {
    ctx.response.status = 200;
    ctx.response.body = bookings;
    console.log("Recherche réservations:", params, bookings.length, "résultats");
  }
});

// DELETE /bookings/:id
router.delete("/bookings/:id", async (ctx) => {
  const id = ctx.params.id;
  const { error, alreadyCancelled, notFound } = await BookingService.deleteBooking(id);
  if (notFound) {
    ctx.response.status = 404;
    ctx.response.body = { error };
    console.log("Annulation réservation inexistante:", id, error);
  } else if (alreadyCancelled) {
    ctx.response.status = 400;
    ctx.response.body = { error };
    console.log("Annulation déjà effectuée:", id, error);
  } else if (error) {
    ctx.response.status = 400;
    ctx.response.body = { error };
    console.log("Erreur annulation réservation:", error);
  } else {
    ctx.response.status = 204;
    ctx.response.body = null;
    console.log("Réservation annulée:", id);
  }
});

router.use(conversationsRouter.routes());
router.use(conversationsRouter.allowedMethods());
router.use(messagesRouter.routes());
router.use(messagesRouter.allowedMethods());
router.use(notificationsRouter.routes());
router.use(notificationsRouter.allowedMethods());

export default router;
