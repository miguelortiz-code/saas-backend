-- ============================================================
--  TENANT TABLES — Se ejecuta al crear una empresa nueva
--  El backend hace: CREATE SCHEMA tenant_xxx;
--                   SET search_path TO tenant_xxx, public;
--                   y luego ejecuta este archivo completo.
-- ============================================================

CREATE TABLE IF NOT EXISTS states (
    id          BIGSERIAL       PRIMARY KEY,
    name        VARCHAR(45)     NOT NULL,
    created_at  TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS roles (
    id          BIGSERIAL       PRIMARY KEY,
    name        VARCHAR(45)     NOT NULL,
    description TEXT            NULL,
    created_at  TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at  TIMESTAMPTZ     NULL
);

CREATE TABLE IF NOT EXISTS modules (
    id          BIGSERIAL       PRIMARY KEY,
    code        VARCHAR(45)     NOT NULL UNIQUE,
    name        VARCHAR(100)    NOT NULL,
    description TEXT            NULL,
    is_active   BOOLEAN         NOT NULL DEFAULT true,
    created_at  TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS permissions (
    id          BIGSERIAL       PRIMARY KEY,
    code        VARCHAR(45)     NOT NULL UNIQUE,
    name        VARCHAR(150)    NOT NULL,
    description VARCHAR(150)    NULL,
    id_module   BIGINT          NOT NULL REFERENCES modules(id) ON DELETE RESTRICT,
    created_at  TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS role_permissions (
    id              BIGSERIAL   PRIMARY KEY,
    id_rol          BIGINT      NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    id_permissions  BIGINT      NOT NULL REFERENCES permissions(id) ON DELETE CASCADE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (id_rol, id_permissions)
);

CREATE TABLE IF NOT EXISTS users (
    id                  BIGSERIAL       PRIMARY KEY,
    code                UUID            NOT NULL DEFAULT gen_random_uuid() UNIQUE,  -- identificador público (URLs)
    id_number           VARCHAR(45)     NOT NULL,
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

CREATE TABLE IF NOT EXISTS categories (
    id          BIGSERIAL       PRIMARY KEY,
    name        VARCHAR(45)     NOT NULL,
    slug        VARCHAR(80)     NOT NULL UNIQUE,
    id_parent   BIGINT          NULL REFERENCES categories(id) ON DELETE SET NULL,
    created_at  TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at  TIMESTAMPTZ     NULL
);

CREATE TABLE IF NOT EXISTS variant_types (
    id          BIGSERIAL       PRIMARY KEY,
    name        VARCHAR(150)    NOT NULL,
    is_active   BOOLEAN         NOT NULL DEFAULT true,
    created_at  TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at  TIMESTAMPTZ     NULL
);

CREATE TABLE IF NOT EXISTS variant_options (
    id              BIGSERIAL       PRIMARY KEY,
    name            VARCHAR(255)    NOT NULL,
    is_active       BOOLEAN         NOT NULL DEFAULT true,
    id_variant_type BIGINT          NOT NULL REFERENCES variant_types(id) ON DELETE RESTRICT,
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ     NULL
);

CREATE TABLE IF NOT EXISTS products (
    id                  BIGSERIAL       PRIMARY KEY,
    code                VARCHAR(45)     NOT NULL UNIQUE,
    name                VARCHAR(150)    NOT NULL,
    slug                VARCHAR(255)    NOT NULL UNIQUE,
    description         TEXT            NULL,
    short_description   TEXT            NULL,
    unit_price          DECIMAL(10,2)   NULL,
    selling_price       DECIMAL(10,2)   NULL,
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

CREATE TABLE IF NOT EXISTS product_variant_options (
    id                  BIGSERIAL   PRIMARY KEY,
    id_product_variant  BIGINT      NOT NULL REFERENCES product_variants(id) ON DELETE CASCADE,
    id_variant_option   BIGINT      NOT NULL REFERENCES variant_options(id) ON DELETE RESTRICT,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at          TIMESTAMPTZ NULL,
    UNIQUE (id_product_variant, id_variant_option)
);

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

CREATE TABLE IF NOT EXISTS inventory_movements (
    id                  BIGSERIAL   PRIMARY KEY,
    quantity            INT         NOT NULL,
    reason              TEXT        NULL,
    id_reference        BIGINT      NULL,
    id_inventory        BIGINT      NOT NULL REFERENCES inventories(id) ON DELETE RESTRICT,
    id_movement_type    BIGINT      NOT NULL REFERENCES movement_types(id) ON DELETE RESTRICT,
    id_user             BIGINT      NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at          TIMESTAMPTZ NULL
);

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

CREATE TABLE IF NOT EXISTS invoices (
    id          BIGSERIAL       PRIMARY KEY,
    number      VARCHAR(45)     NOT NULL,
    prefix      VARCHAR(10)     NOT NULL,
    issue_date  TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    due_date    TIMESTAMPTZ     NULL,
    cufe        VARCHAR(255)    NOT NULL,
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

CREATE TABLE IF NOT EXISTS audit_logs (
    id          BIGSERIAL       PRIMARY KEY,
    action      VARCHAR(100)    NOT NULL,
    description TEXT            NULL,
    ip_address  VARCHAR(45)     NOT NULL,
    id_user     BIGINT          NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    id_module   BIGINT          NOT NULL REFERENCES modules(id) ON DELETE RESTRICT,
    created_at  TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS audit_logs_details (
    id              BIGSERIAL    PRIMARY KEY,
    field           VARCHAR(100) NOT NULL,
    old_value       TEXT         NULL,
    new_value       TEXT         NULL,
    id_audit_log    BIGINT       NOT NULL REFERENCES audit_logs(id) ON DELETE CASCADE,
    created_at      TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

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

-- Seeds automáticos
INSERT INTO states (name) VALUES
    ('Activo'), ('Inactivo'), ('Pendiente'), ('En proceso'),
    ('Completado'), ('Cancelado'), ('Enviado'), ('Entregado'),
    ('Devuelto'), ('Borrador'), ('Aprobado'), ('Rechazado'), ('Archivado');

INSERT INTO roles (name, description) VALUES
    ('superadmin', 'Acceso total al sistema'),
    ('admin',      'Administrador de la empresa'),
    ('vendedor',   'Gestión de ventas y cotizaciones'),
    ('cajero',     'Punto de venta y facturación');

INSERT INTO modules (code, name, description) VALUES
    ('DASHBOARD',   'Dashboard',     'Panel de estadísticas generales'),
    ('PRODUCTS',    'Productos',     'Gestión del catálogo de productos'),
    ('INVENTORY',   'Inventario',    'Control de stock y movimientos'),
    ('ORDERS',      'Pedidos',       'Gestión de pedidos de clientes'),
    ('QUOTES',      'Cotizaciones',  'Creación y seguimiento de cotizaciones'),
    ('INVOICES',    'Facturación',   'Facturación electrónica DIAN'),
    ('USERS',       'Usuarios',      'Gestión de usuarios y roles'),
    ('SETTINGS',    'Configuración', 'Configuración de la empresa'),
    ('STORE',       'Tienda',        'Tienda virtual'),
    ('REPORTS',     'Reportes',      'Reportes y estadísticas'),
    ('BULK_UPLOAD', 'Carga Masiva',  'Importación masiva de productos por Excel'),
    ('AI_ASSIST',   'Inocensar',     'Asistente IA interno del panel administrativo');

INSERT INTO movement_types (name, description, direction) VALUES
    ('Compra',               'Entrada por compra a proveedor',         'Entrada'),
    ('Venta',                'Salida por venta a cliente',             'Salida'),
    ('Ajuste positivo',      'Corrección manual al alza',              'Ajuste'),
    ('Ajuste negativo',      'Corrección manual a la baja',            'Ajuste'),
    ('Devolución cliente',   'Entrada por devolución de cliente',      'Entrada'),
    ('Devolución proveedor', 'Salida por devolución a proveedor',      'Salida'),
    ('Traslado',             'Movimiento entre bodegas o ubicaciones', 'Ajuste');