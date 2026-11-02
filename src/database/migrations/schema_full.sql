-- ============================================================
--  SCHEMA COMPLETO — Multi-Tenant SaaS para PyMEs Colombianas
--  PostgreSQL 14+
--  Generado desde modelo MySQL Workbench y adaptado a PG
--  Estructura:
--    · public.*  → tablas globales compartidas por todos los tenants
--    · tenant_*  → esquema por empresa (se crea al registrar una empresa)
-- ============================================================


-- ============================================================
--  SECCIÓN 1 — TABLAS PÚBLICAS (ejecutar una sola vez)
-- ============================================================

-- ------------------------------------------------------------
--  departaments — Departamentos de Colombia
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.departaments (
    id          BIGSERIAL       PRIMARY KEY,
    code        VARCHAR(5)      NOT NULL UNIQUE,
    name        VARCHAR(100)    NOT NULL,
    created_at  TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

-- ------------------------------------------------------------
--  cities — Municipios de Colombia
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.cities (
    id              BIGSERIAL       PRIMARY KEY,
    code            VARCHAR(10)     NOT NULL UNIQUE,
    name            VARCHAR(100)    NOT NULL,
    id_departament  BIGINT          NOT NULL REFERENCES public.departaments(id) ON DELETE RESTRICT,
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

-- ------------------------------------------------------------
--  document_types — Tipos de documento (CC, NIT, CE, etc.)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.document_types (
    id      BIGSERIAL       PRIMARY KEY,
    code    VARCHAR(45)     NOT NULL UNIQUE,
    name    VARCHAR(45)     NOT NULL
);

-- ------------------------------------------------------------
--  person_types — Persona natural o jurídica
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.person_types (
    id      BIGSERIAL   PRIMARY KEY,
    name    VARCHAR(45) NOT NULL
);

-- ------------------------------------------------------------
--  companies — Registro de empresas (tenants)
--  Cada empresa tiene su propio schema en PostgreSQL
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.companies (
    id          BIGSERIAL       PRIMARY KEY,
    uuid        UUID            NOT NULL DEFAULT gen_random_uuid() UNIQUE,
    schema_name VARCHAR(63)     NOT NULL UNIQUE,  -- ej: tenant_empresa_abc
    name        VARCHAR(150)    NOT NULL,
    nit         VARCHAR(20)     NOT NULL UNIQUE,
    email       VARCHAR(150)    NOT NULL,
    phone       VARCHAR(20)     NULL,
    plan        VARCHAR(30)     NOT NULL DEFAULT 'basic',
    is_active   BOOLEAN         NOT NULL DEFAULT true,
    created_at  TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at  TIMESTAMPTZ     NULL
);

-- ------------------------------------------------------------
--  Datos iniciales de las tablas públicas (ejecutar una sola vez)
--  Deben existir antes de crear usuarios en cualquier tenant
-- ------------------------------------------------------------

-- Tipos de documento (códigos DIAN)
INSERT INTO public.document_types (code, name) VALUES
    ('13', 'Cédula de ciudadanía'),
    ('31', 'NIT'),
    ('22', 'Cédula de extranjería'),
    ('12', 'Tarjeta de identidad'),
    ('41', 'Pasaporte'),
    ('47', 'Permiso especial de permanencia')
ON CONFLICT (code) DO NOTHING;

-- Tipos de persona
INSERT INTO public.person_types (name) VALUES
    ('Persona natural'),
    ('Persona jurídica');

-- Departamentos (códigos DANE)
INSERT INTO public.departaments (code, name) VALUES
    ('05', 'Antioquia'),
    ('08', 'Atlántico'),
    ('11', 'Bogotá D.C.'),
    ('13', 'Bolívar'),
    ('15', 'Boyacá'),
    ('17', 'Caldas'),
    ('18', 'Caquetá'),
    ('19', 'Cauca'),
    ('20', 'Cesar'),
    ('23', 'Córdoba'),
    ('25', 'Cundinamarca'),
    ('27', 'Chocó'),
    ('41', 'Huila'),
    ('44', 'La Guajira'),
    ('47', 'Magdalena'),
    ('50', 'Meta'),
    ('52', 'Nariño'),
    ('54', 'Norte de Santander'),
    ('63', 'Quindío'),
    ('66', 'Risaralda'),
    ('68', 'Santander'),
    ('70', 'Sucre'),
    ('73', 'Tolima'),
    ('76', 'Valle del Cauca'),
    ('81', 'Arauca'),
    ('85', 'Casanare'),
    ('86', 'Putumayo'),
    ('88', 'San Andrés y Providencia'),
    ('91', 'Amazonas'),
    ('94', 'Guainía'),
    ('95', 'Guaviare'),
    ('97', 'Vaupés'),
    ('99', 'Vichada')
ON CONFLICT (code) DO NOTHING;

-- Ciudades (capitales y principales municipios, códigos DANE)
-- Lista parcial: se puede completar después con el listado oficial del DANE
INSERT INTO public.cities (code, name, id_departament)
SELECT v.code, v.name, d.id
FROM (VALUES
    ('05001', 'Medellín',                 '05'),
    ('05045', 'Apartadó',                 '05'),
    ('05088', 'Bello',                    '05'),
    ('05266', 'Envigado',                 '05'),
    ('05360', 'Itagüí',                   '05'),
    ('05615', 'Rionegro',                 '05'),
    ('08001', 'Barranquilla',             '08'),
    ('08758', 'Soledad',                  '08'),
    ('11001', 'Bogotá D.C.',              '11'),
    ('13001', 'Cartagena',                '13'),
    ('13836', 'Turbaco',                  '13'),
    ('15001', 'Tunja',                    '15'),
    ('15238', 'Duitama',                  '15'),
    ('15759', 'Sogamoso',                 '15'),
    ('17001', 'Manizales',                '17'),
    ('18001', 'Florencia',                '18'),
    ('19001', 'Popayán',                  '19'),
    ('20001', 'Valledupar',               '20'),
    ('23001', 'Montería',                 '23'),
    ('25175', 'Chía',                     '25'),
    ('25269', 'Facatativá',               '25'),
    ('25754', 'Soacha',                   '25'),
    ('25899', 'Zipaquirá',                '25'),
    ('27001', 'Quibdó',                   '27'),
    ('41001', 'Neiva',                    '41'),
    ('44001', 'Riohacha',                 '44'),
    ('44430', 'Maicao',                   '44'),
    ('47001', 'Santa Marta',              '47'),
    ('47189', 'Ciénaga',                  '47'),
    ('50001', 'Villavicencio',            '50'),
    ('52001', 'Pasto',                    '52'),
    ('52356', 'Ipiales',                  '52'),
    ('54001', 'Cúcuta',                   '54'),
    ('63001', 'Armenia',                  '63'),
    ('66001', 'Pereira',                  '66'),
    ('66170', 'Dosquebradas',             '66'),
    ('68001', 'Bucaramanga',              '68'),
    ('68081', 'Barrancabermeja',          '68'),
    ('68276', 'Floridablanca',            '68'),
    ('68307', 'Girón',                    '68'),
    ('70001', 'Sincelejo',                '70'),
    ('73001', 'Ibagué',                   '73'),
    ('76001', 'Cali',                     '76'),
    ('76109', 'Buenaventura',             '76'),
    ('76520', 'Palmira',                  '76'),
    ('76834', 'Tuluá',                    '76'),
    ('81001', 'Arauca',                   '81'),
    ('85001', 'Yopal',                    '85'),
    ('86001', 'Mocoa',                    '86'),
    ('88001', 'San Andrés',               '88'),
    ('91001', 'Leticia',                  '91'),
    ('94001', 'Inírida',                  '94'),
    ('95001', 'San José del Guaviare',    '95'),
    ('97001', 'Mitú',                     '97'),
    ('99001', 'Puerto Carreño',           '99')
) AS v(code, name, dep_code)
JOIN public.departaments d ON d.code = v.dep_code
ON CONFLICT (code) DO NOTHING;


-- ============================================================
--  SECCIÓN 2 — TABLAS DE TENANT
--  Todo lo de abajo se ejecuta dentro del schema del tenant:
--    SET search_path TO tenant_xxx, public;
--  O se copia en database/migrations/tenant_tables.sql
-- ============================================================

-- ------------------------------------------------------------
--  states — Estados reutilizables (activo, inactivo, pendiente…)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS states (
    id          BIGSERIAL       PRIMARY KEY,
    name        VARCHAR(45)     NOT NULL,
    created_at  TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

-- ------------------------------------------------------------
--  roles — Roles del sistema (superadmin, admin, vendedor…)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS roles (
    id          BIGSERIAL       PRIMARY KEY,
    name        VARCHAR(45)     NOT NULL,
    description TEXT            NULL,
    created_at  TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at  TIMESTAMPTZ     NULL
);

-- ------------------------------------------------------------
--  modules — Módulos del sistema (productos, inventario…)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS modules (
    id          BIGSERIAL       PRIMARY KEY,
    code        VARCHAR(45)     NOT NULL UNIQUE,
    name        VARCHAR(100)    NOT NULL,
    description TEXT            NULL,
    is_active   BOOLEAN         NOT NULL DEFAULT true,
    created_at  TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

-- ------------------------------------------------------------
--  permissions — Permisos por módulo (crear, editar, eliminar…)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS permissions (
    id          BIGSERIAL       PRIMARY KEY,
    code        VARCHAR(45)     NOT NULL UNIQUE,
    name        VARCHAR(150)    NOT NULL,
    description VARCHAR(150)    NULL,
    id_module   BIGINT          NOT NULL REFERENCES modules(id) ON DELETE RESTRICT,
    created_at  TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

-- ------------------------------------------------------------
--  role_permissions — Pivote N:M roles ↔ permissions
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS role_permissions (
    id              BIGSERIAL   PRIMARY KEY,
    id_rol          BIGINT      NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    id_permissions  BIGINT      NOT NULL REFERENCES permissions(id) ON DELETE CASCADE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (id_rol, id_permissions)
);

-- ------------------------------------------------------------
--  users — Usuarios del tenant
--  · uuid  → identificador público (URLs, APIs externas)
--  · id    → clave interna para JOINs y FKs
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS users (
    id                  BIGSERIAL       PRIMARY KEY,
    code                UUID            NOT NULL DEFAULT gen_random_uuid() UNIQUE,  -- identificador público (URLs)
    id_number           VARCHAR(45)     NOT NULL,           -- número de documento
    first_name          VARCHAR(80)     NOT NULL,
    middle_name         VARCHAR(60)     NULL,
    lastname            VARCHAR(80)     NOT NULL,
    middle_lastname     VARCHAR(60)     NULL,
    phone               VARCHAR(20)     NOT NULL,
    address             VARCHAR(255)    NULL,
    image               VARCHAR(255)    NULL,
    email               VARCHAR(255)    NOT NULL UNIQUE,
    password            VARCHAR(255)    NOT NULL,
    super_admin         BOOLEAN         NOT NULL DEFAULT false,
    id_state            BIGINT          NOT NULL REFERENCES states(id) ON DELETE RESTRICT,
    id_rol              BIGINT          NOT NULL REFERENCES roles(id) ON DELETE RESTRICT,
    id_document_type    BIGINT          NOT NULL REFERENCES public.document_types(id) ON DELETE RESTRICT,
    id_person_type      BIGINT          NOT NULL REFERENCES public.person_types(id) ON DELETE RESTRICT,
    id_departament      BIGINT          NOT NULL REFERENCES public.departaments(id) ON DELETE RESTRICT,
    id_city             BIGINT          NOT NULL REFERENCES public.cities(id) ON DELETE RESTRICT,
    created_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at          TIMESTAMPTZ     NULL
);

-- ------------------------------------------------------------
--  settings — Configuración de la empresa dentro del tenant
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS settings (
    id              BIGSERIAL       PRIMARY KEY,
    nit             VARCHAR(15)     NOT NULL,
    company_name    VARCHAR(255)    NOT NULL,
    trade_name      VARCHAR(80)     NULL,
    address         VARCHAR(255)    NOT NULL,
    image           VARCHAR(255)    NULL,
    ciiu            VARCHAR(10)     NOT NULL,
    tax_regime      VARCHAR(50)     NOT NULL,
    tax_name        VARCHAR(20)     NOT NULL,
    tax_percentage  DECIMAL(5,2)    NOT NULL,
    email           VARCHAR(255)    NOT NULL,
    phone           VARCHAR(20)     NOT NULL,
    domain_web      VARCHAR(150)    NULL,
    domain_store    VARCHAR(150)    NULL,
    domain_login    VARCHAR(150)    NULL,
    primary_color   VARCHAR(10)     NOT NULL DEFAULT '#000000',
    secondary_color VARCHAR(10)     NOT NULL DEFAULT '#ffffff',
    favicon         VARCHAR(255)    NULL,
    id_departament  BIGINT          NOT NULL REFERENCES public.departaments(id) ON DELETE RESTRICT,
    id_city         BIGINT          NOT NULL REFERENCES public.cities(id) ON DELETE RESTRICT,
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ     NULL
);

-- ------------------------------------------------------------
--  categories — Categorías de productos (árbol recursivo)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS categories (
    id          BIGSERIAL       PRIMARY KEY,
    name        VARCHAR(45)     NOT NULL,
    slug        VARCHAR(80)     NOT NULL UNIQUE,
    id_parent   BIGINT          NULL REFERENCES categories(id) ON DELETE SET NULL,
    created_at  TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at  TIMESTAMPTZ     NULL
);

-- ------------------------------------------------------------
--  variant_types — Tipos de variante (Talla, Color, Material…)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS variant_types (
    id          BIGSERIAL       PRIMARY KEY,
    name        VARCHAR(150)    NOT NULL,
    is_active   BOOLEAN         NOT NULL DEFAULT true,
    created_at  TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at  TIMESTAMPTZ     NULL
);

-- ------------------------------------------------------------
--  variant_options — Opciones de cada variante (S, M, L / Rojo…)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS variant_options (
    id              BIGSERIAL       PRIMARY KEY,
    name            VARCHAR(255)    NOT NULL,
    is_active       BOOLEAN         NOT NULL DEFAULT true,
    id_variant_type BIGINT          NOT NULL REFERENCES variant_types(id) ON DELETE RESTRICT,
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ     NULL
);

-- ------------------------------------------------------------
--  products — Catálogo de productos
--  · code  → código de barras o código interno generado
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS products (
    id                  BIGSERIAL       PRIMARY KEY,
    code                VARCHAR(45)     NOT NULL UNIQUE,    -- código de barras o autogenerado
    name                VARCHAR(150)    NOT NULL,
    slug                VARCHAR(255)    NOT NULL UNIQUE,
    description         TEXT            NULL,
    short_description   TEXT            NULL,
    unit_price          DECIMAL(10,2)   NULL,               -- precio de compra/costo
    selling_price       DECIMAL(10,2)   NULL,               -- precio de venta
    brand               VARCHAR(45)     NULL,
    tax_percentage      DECIMAL(5,2)    NOT NULL DEFAULT 0,
    tax_included        BOOLEAN         NOT NULL DEFAULT false,
    is_active           BOOLEAN         NOT NULL DEFAULT true,
    is_featured         BOOLEAN         NOT NULL DEFAULT false,
    id_category         BIGINT          NOT NULL REFERENCES categories(id) ON DELETE RESTRICT,
    id_state            BIGINT          NOT NULL REFERENCES states(id) ON DELETE RESTRICT,
    created_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at          TIMESTAMPTZ     NULL
);

-- ------------------------------------------------------------
--  product_variants — Variantes de un producto (talla+color combo)
--  · uuid  → identificador público
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS product_variants (
    id              BIGSERIAL       PRIMARY KEY,
    code            UUID            NOT NULL DEFAULT gen_random_uuid() UNIQUE,  -- identificador público (URLs)
    unit_price      DECIMAL(10,2)   NULL,
    selling_price   DECIMAL(10,2)   NULL,
    is_active       BOOLEAN         NOT NULL DEFAULT true,
    id_product      BIGINT          NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ     NULL
);

-- ------------------------------------------------------------
--  product_variant_options — Pivote N:M variantes ↔ opciones
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS product_variant_options (
    id                  BIGSERIAL   PRIMARY KEY,
    id_product_variant  BIGINT      NOT NULL REFERENCES product_variants(id) ON DELETE CASCADE,
    id_variant_option   BIGINT      NOT NULL REFERENCES variant_options(id) ON DELETE RESTRICT,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at          TIMESTAMPTZ NULL,
    UNIQUE (id_product_variant, id_variant_option)
);

-- ------------------------------------------------------------
--  product_images — Imágenes de producto y variante
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS product_images (
    id                  BIGSERIAL       PRIMARY KEY,
    url                 VARCHAR(255)    NULL,
    "order"             INT             NOT NULL DEFAULT 0,
    is_main             BOOLEAN         NOT NULL DEFAULT false,
    id_product          BIGINT          NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    id_product_variant  BIGINT          NULL REFERENCES product_variants(id) ON DELETE SET NULL,
    created_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

-- ------------------------------------------------------------
--  product_combos — Combos/bundles de productos
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS product_combos (
    id                  BIGSERIAL   PRIMARY KEY,
    quantity            INT         NOT NULL DEFAULT 1,
    id_product_bundle   BIGINT      NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    id_product_item     BIGINT      NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at          TIMESTAMPTZ NULL,
    UNIQUE (id_product_bundle, id_product_item)
);

-- ------------------------------------------------------------
--  inventories — Stock por producto y variante
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS inventories (
    id                  BIGSERIAL   PRIMARY KEY,
    stock               INT         NOT NULL DEFAULT 0,
    min_stock           INT         NOT NULL DEFAULT 0,
    id_product          BIGINT      NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
    id_product_variant  BIGINT      NULL REFERENCES product_variants(id) ON DELETE SET NULL,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at          TIMESTAMPTZ NULL
);

-- ------------------------------------------------------------
--  movement_types — Tipos de movimiento de inventario
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS movement_types (
    id          BIGSERIAL       PRIMARY KEY,
    name        VARCHAR(100)    NOT NULL,
    description TEXT            NULL,
    direction   VARCHAR(10)     NOT NULL CHECK (direction IN ('Entrada', 'Salida', 'Ajuste')),
    is_active   BOOLEAN         NOT NULL DEFAULT true,
    created_at  TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at  TIMESTAMPTZ     NULL
);

-- ------------------------------------------------------------
--  inventory_movements — Historial de movimientos de stock
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS inventory_movements (
    id                  BIGSERIAL   PRIMARY KEY,
    quantity            INT         NOT NULL,
    reason              TEXT        NULL,
    id_reference        BIGINT      NULL,   -- ID del pedido/ajuste que originó el movimiento
    id_inventory        BIGINT      NOT NULL REFERENCES inventories(id) ON DELETE RESTRICT,
    id_movement_type    BIGINT      NOT NULL REFERENCES movement_types(id) ON DELETE RESTRICT,
    id_user             BIGINT      NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at          TIMESTAMPTZ NULL
);

-- ------------------------------------------------------------
--  quotes — Cotizaciones
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS quotes (
    id              BIGSERIAL       PRIMARY KEY,
    code            VARCHAR(45)     NOT NULL UNIQUE,
    notes           TEXT            NULL,
    validity_days   INT             NULL,
    subtotal        DECIMAL(10,2)   NOT NULL DEFAULT 0,
    tax_amount      DECIMAL(10,2)   NOT NULL DEFAULT 0,
    discount        DECIMAL(10,2)   NULL DEFAULT 0,
    total           DECIMAL(10,2)   NOT NULL DEFAULT 0,
    id_state        BIGINT          NOT NULL REFERENCES states(id) ON DELETE RESTRICT,
    id_user         BIGINT          NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ     NULL
);

-- ------------------------------------------------------------
--  quotes_details — Detalle de líneas de cotización
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS quotes_details (
    id                  BIGSERIAL       PRIMARY KEY,
    quantity            INT             NOT NULL,
    unit_price          DECIMAL(10,2)   NOT NULL,
    discount            DECIMAL(5,2)    NULL DEFAULT 0,
    subtotal            DECIMAL(10,2)   NOT NULL,
    id_quote            BIGINT          NOT NULL REFERENCES quotes(id) ON DELETE CASCADE,
    id_product          BIGINT          NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
    id_product_variant  BIGINT          NULL REFERENCES product_variants(id) ON DELETE SET NULL,
    created_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at          TIMESTAMPTZ     NULL
);

-- ------------------------------------------------------------
--  orders — Pedidos (desde tienda o panel admin)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS orders (
    id                      BIGSERIAL       PRIMARY KEY,
    code                    VARCHAR(45)     NOT NULL UNIQUE,
    notes                   TEXT            NULL,
    shipping_address        VARCHAR(255)    NULL,
    shipping_city           VARCHAR(255)    NULL,
    shipping_department     VARCHAR(255)    NULL,
    subtotal                DECIMAL(10,2)   NOT NULL DEFAULT 0,
    tax_amount              DECIMAL(10,2)   NOT NULL DEFAULT 0,
    discount                DECIMAL(10,2)   NULL DEFAULT 0,
    total                   DECIMAL(10,2)   NOT NULL DEFAULT 0,
    id_state                BIGINT          NOT NULL REFERENCES states(id) ON DELETE RESTRICT,
    id_user                 BIGINT          NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    id_quote                BIGINT          NULL REFERENCES quotes(id) ON DELETE SET NULL,
    id_module               BIGINT          NOT NULL REFERENCES modules(id) ON DELETE RESTRICT,
    created_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at              TIMESTAMPTZ     NULL
);

-- ------------------------------------------------------------
--  order_details — Detalle de líneas de pedido
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS order_details (
    id                  BIGSERIAL       PRIMARY KEY,
    quantity            INT             NOT NULL,
    unit_price          DECIMAL(10,2)   NOT NULL,
    discount            DECIMAL(5,2)    NULL DEFAULT 0,
    subtotal            DECIMAL(10,2)   NOT NULL,
    id_order            BIGINT          NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    id_product          BIGINT          NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
    id_product_variant  BIGINT          NULL REFERENCES product_variants(id) ON DELETE SET NULL,
    created_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at          TIMESTAMPTZ     NULL
);

-- ------------------------------------------------------------
--  invoices — Facturas electrónicas
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS invoices (
    id          BIGSERIAL       PRIMARY KEY,
    number      VARCHAR(45)     NOT NULL,
    prefix      VARCHAR(10)     NOT NULL,
    issue_date  TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    due_date    TIMESTAMPTZ     NULL,
    cufe        VARCHAR(255)    NOT NULL,               -- Código Único de Factura Electrónica (DIAN)
    subtotal    DECIMAL(10,2)   NOT NULL DEFAULT 0,
    tax_amount  DECIMAL(10,2)   NOT NULL DEFAULT 0,
    discount    DECIMAL(10,2)   NULL DEFAULT 0,
    total       DECIMAL(10,2)   NOT NULL DEFAULT 0,
    notes       TEXT            NULL,
    id_state    BIGINT          NOT NULL REFERENCES states(id) ON DELETE RESTRICT,
    id_user     BIGINT          NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    id_order    BIGINT          NOT NULL REFERENCES orders(id) ON DELETE RESTRICT,
    created_at  TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at  TIMESTAMPTZ     NULL
);

-- ------------------------------------------------------------
--  invoice_details — Detalle de líneas de factura
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS invoice_details (
    id                  BIGSERIAL       PRIMARY KEY,
    quantity            INT             NOT NULL,
    unit_price          DECIMAL(10,2)   NOT NULL,
    tax_percentage      DECIMAL(5,2)    NOT NULL DEFAULT 0,
    discount            DECIMAL(5,2)    NULL DEFAULT 0,
    subtotal            DECIMAL(10,2)   NOT NULL,
    id_invoice          BIGINT          NOT NULL REFERENCES invoices(id) ON DELETE CASCADE,
    id_product          BIGINT          NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
    id_product_variant  BIGINT          NULL REFERENCES product_variants(id) ON DELETE SET NULL,
    created_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at          TIMESTAMPTZ     NULL
);

-- ------------------------------------------------------------
--  pages — Páginas de la tienda (Quiénes somos, Contacto…)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS pages (
    id                  BIGSERIAL       PRIMARY KEY,
    title               VARCHAR(100)    NOT NULL,
    slug                VARCHAR(100)    NOT NULL UNIQUE,
    content             TEXT            NULL,
    meta_title          VARCHAR(255)    NULL,
    meta_description    TEXT            NULL,
    is_active           BOOLEAN         NOT NULL DEFAULT true,
    "order"             INT             NOT NULL DEFAULT 0,
    created_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at          TIMESTAMPTZ     NULL
);

-- ------------------------------------------------------------
--  menu_items — Ítems del menú de navegación de la tienda
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS menu_items (
    id          BIGSERIAL       PRIMARY KEY,
    label       VARCHAR(100)    NOT NULL,
    "order"     INT             NOT NULL DEFAULT 0,
    is_active   BOOLEAN         NOT NULL DEFAULT true,
    id_page     BIGINT          NULL REFERENCES pages(id) ON DELETE SET NULL,
    id_parent   BIGINT          NULL REFERENCES menu_items(id) ON DELETE SET NULL,
    created_at  TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at  TIMESTAMPTZ     NULL
);

-- ------------------------------------------------------------
--  audit_logs — Registro de acciones del usuario
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS audit_logs (
    id          BIGSERIAL       PRIMARY KEY,
    action      VARCHAR(100)    NOT NULL,
    description TEXT            NULL,
    ip_address  VARCHAR(45)     NOT NULL,
    id_user     BIGINT          NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    id_module   BIGINT          NOT NULL REFERENCES modules(id) ON DELETE RESTRICT,
    created_at  TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

-- ------------------------------------------------------------
--  audit_logs_details — Detalle campo a campo de cada cambio
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS audit_logs_details (
    id              BIGSERIAL   PRIMARY KEY,
    field           VARCHAR(100) NOT NULL,
    old_value       TEXT        NULL,
    new_value       TEXT        NULL,
    id_audit_log    BIGINT      NOT NULL REFERENCES audit_logs(id) ON DELETE CASCADE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ------------------------------------------------------------
--  sql_queries — Consultas SQL guardadas por el usuario/admin
--  (usado por el módulo "Inocensar" — IA interna del panel)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS sql_queries (
    id          BIGSERIAL       PRIMARY KEY,
    name        VARCHAR(150)    NULL,
    description TEXT            NULL,
    query       TEXT            NULL,
    is_active   BOOLEAN         NOT NULL DEFAULT true,
    id_user     BIGINT          NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    created_at  TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at  TIMESTAMPTZ     NULL
);


-- ============================================================
--  SECCIÓN 3 — SEEDS INICIALES POR TENANT
--  Se insertan automáticamente al crear un tenant nuevo
-- ============================================================

-- States
INSERT INTO states (name) VALUES
    ('Activo'),
    ('Inactivo'),
    ('Pendiente'),
    ('En proceso'),
    ('Completado'),
    ('Cancelado'),
    ('Enviado'),
    ('Entregado'),
    ('Devuelto'),
    ('Borrador'),
    ('Aprobado'),
    ('Rechazado'),
    ('Archivado');

-- Roles
INSERT INTO roles (name, description) VALUES
    ('superadmin', 'Acceso total al sistema'),
    ('admin',      'Administrador de la empresa'),
    ('vendedor',   'Gestión de ventas y cotizaciones'),
    ('cajero',     'Punto de venta y facturación');

-- Modules
INSERT INTO modules (code, name, description) VALUES
    ('DASHBOARD',   'Dashboard',         'Panel de estadísticas generales'),
    ('PRODUCTS',    'Productos',         'Gestión del catálogo de productos'),
    ('INVENTORY',   'Inventario',        'Control de stock y movimientos'),
    ('ORDERS',      'Pedidos',           'Gestión de pedidos de clientes'),
    ('QUOTES',      'Cotizaciones',      'Creación y seguimiento de cotizaciones'),
    ('INVOICES',    'Facturación',       'Facturación electrónica DIAN'),
    ('USERS',       'Usuarios',          'Gestión de usuarios y roles'),
    ('SETTINGS',    'Configuración',     'Configuración de la empresa'),
    ('STORE',       'Tienda',            'Tienda virtual'),
    ('REPORTS',     'Reportes',          'Reportes y estadísticas'),
    ('BULK_UPLOAD', 'Carga Masiva',      'Importación masiva de productos por Excel'),
    ('AI_ASSIST',   'Inocensar',         'Asistente IA interno del panel administrativo');

-- Movement types
INSERT INTO movement_types (name, description, direction) VALUES
    ('Compra',              'Entrada por compra a proveedor',           'Entrada'),
    ('Venta',               'Salida por venta a cliente',               'Salida'),
    ('Ajuste positivo',     'Corrección manual al alza',                'Ajuste'),
    ('Ajuste negativo',     'Corrección manual a la baja',              'Ajuste'),
    ('Devolución cliente',  'Entrada por devolución de cliente',        'Entrada'),
    ('Devolución proveedor','Salida por devolución a proveedor',        'Salida'),
    ('Traslado',            'Movimiento entre bodegas o ubicaciones',   'Ajuste');

-- Usuario superadmin de desarrollo
-- Requiere los datos de las tablas públicas (Sección 1) y los seeds de arriba
-- Contraseña inicial: Admin2024*  (cambiarla después)
-- Solo para desarrollo: en una empresa real el admin se crea desde el backend
INSERT INTO users (
    id_number, first_name, lastname, phone, email, password, super_admin,
    id_state, id_rol, id_document_type, id_person_type, id_departament, id_city
) VALUES (
    '1000000000',
    'Miguel',
    'Aya Ortiz',
    '3000000000',
    'miguelortiz.code@gmail.com',
    '$2a$10$qzrJ6ytfYN75hs0qeQLJjuYHRtXF3g6zEAKU7lo49foyQWdoj1bLm',
    true,
    (SELECT id FROM states WHERE name = 'Activo'),
    (SELECT id FROM roles  WHERE name = 'superadmin'),
    (SELECT id FROM public.document_types WHERE code = '13'),
    (SELECT id FROM public.person_types   WHERE name = 'Persona natural'),
    (SELECT id FROM public.departaments   WHERE code = '11'),
    (SELECT id FROM public.cities         WHERE code = '11001')
)
ON CONFLICT (email) DO NOTHING;