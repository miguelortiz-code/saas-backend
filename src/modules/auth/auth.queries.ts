import { query, tenantQuery } from '../../config/database.js';

// Busca un usuario por email recorriendo todas las empresas activas
// Se usa en el login — no sabemos a qué tenant pertenece hasta encontrarlo
export const findUserByEmail = async (email: string) => {
  const companies = await query(
    `SELECT id, schema_name
     FROM public.companies
     WHERE is_active = true AND deleted_at IS NULL`
  );

  for (const company of companies.rows) {
    const result = await tenantQuery(
      company.schema_name,
      `SELECT
         u.id,
         u.code,
         u.first_name,
         u.lastname,
         u.email,
         u.password,
         u.super_admin,
         r.name        AS role_name,
         $2::bigint    AS company_id,
         $3::varchar   AS schema_name
       FROM users u
       JOIN roles r ON r.id = u.id_rol
       JOIN states s ON s.id = u.id_state
       WHERE u.email = $1
         AND u.deleted_at IS NULL
         AND s.name = 'Activo'
       LIMIT 1`,
      [email, company.id, company.schema_name]
    );

    if (result.rows.length > 0) return result.rows[0];
  }

  return null;
};

// Busca un usuario por su id interno dentro de su propio schema
// Se usa para validar el token JWT en cada petición autenticada
export const findUserById = async (id: number, schemaName: string) => {
  const result = await tenantQuery(
    schemaName,
    `SELECT
       u.id,
       u.code,
       u.first_name,
       u.lastname,
       u.email,
       u.super_admin,
       r.name AS role_name
     FROM users u
     JOIN roles r ON r.id = u.id_rol
     JOIN states s ON s.id = u.id_state
     WHERE u.id = $1
       AND u.deleted_at IS NULL
       AND s.name = 'Activo'`,
    [id]
  );

  return result.rows[0] || null;
};

// Buscar una empresa por su ID
export const findCompanyById = async(id: number) => {
  const result = await query(
    `SELECT id
     FROM public.companies
     WHERE is_active = true AND deleted_at IS NULL  AND id = $1`,
     [id]
  );

  return result.rows[0] || null;
};