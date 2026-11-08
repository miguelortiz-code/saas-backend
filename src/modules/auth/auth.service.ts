import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import { ENV } from "../../config/env.js";
import { AppError } from "../../middleware/error.middleware.js";
import { findUserByEmail, findUserById, findCompanyById } from "./auth.queries.js";

// Genera el access token (15 minutos)
const generateAccessToken = (payload: object): string =>
  jwt.sign(payload, ENV.JWT.SECRET, {
    expiresIn: ENV.JWT.EXPIRES_IN as jwt.SignOptions["expiresIn"],
  });

// Genera el refresh token (7 días)
const generateRefreshToken = (payload: object): string =>
  jwt.sign(payload, ENV.JWT.REFRESH_SECRET, {
    expiresIn: ENV.JWT.REFRESH_EXPIRES as jwt.SignOptions["expiresIn"],
  });

// Hash falso para igualar el tiempo de respuesta cuando el email no existe
const DUMMY_HASH = bcrypt.hashSync("contraseña-falsa", 10);

// Login — valida credenciales y retorna los dos tokens
export const loginService = async (email: string, password: string) => {
  // Buscar usuario por email
  const user = await findUserByEmail(email);

  // bcrypt se ejecuta siempre, exista o no el usuario, para que el tiempo
  // de respuesta no revele qué emails están registrados
  const passwordMatch = await bcrypt.compare(
    password,
    user ? user.password : DUMMY_HASH,
  );

  // Mismo mensaje para email inexistente y contraseña incorrecta
  if (!user || !passwordMatch)
    throw new AppError("Credenciales incorrectas", 401);

  // Payload que viaja dentro del JWT

  const payload = {
    id: user.id,
    code: user.code,
    email: user.email,
    role: user.role_name,
    schemaName: user.schema_name,
    companyId: user.company_id,
  };

  return {
    accessToken: generateAccessToken(payload),
    refreshToken: generateRefreshToken(payload),
    user: {
      code: user.code,
      firstName: user.first_name,
      lastName: user.lastname,
      email: user.email,
      rol: user.role_name,
    },
  };
};

// Refresh token — valida el refresh y emite un nuevo access token
export const refreshTokenService = async (refreshToken: string) => {
  let decoded: jwt.JwtPayload;

  try {
    decoded = jwt.verify(
      refreshToken,
      ENV.JWT.REFRESH_SECRET,
    ) as jwt.JwtPayload;
  } catch {
    throw new AppError("Refresh token inválido o expirado", 401);
  }

  // Verifica que la empresa y el usuario siga existiendo y activo  
  const company = await findCompanyById(decoded["companyId"]);
  if(!company) throw new AppError("Empresa inactiva", 401);
  
  const user = await findUserById(decoded["id"], decoded["schemaName"]);
  if (!user) throw new AppError("Usuario no encontrado", 401);

  const payload = {
    id: user.id,
    code: user.code,
    email: user.email,
    role: user.role_name,
    schemaName: decoded["schemaName"],
    companyId: decoded["companyId"],
  };

  return {
    accessToken: generateAccessToken(payload),
  };
};

// Me — retorna el perfil del usuario autenticado
export const getMeService = async (id: number, schemaName: string) => {
  const user = await findUserById(id, schemaName);
  if (!user) throw new AppError("Usuario no encontrado", 401);

  return {
    code: user.code,
    firstName: user.first_name,
    lastName: user.lastname,
    email: user.email,
    rol: user.role_name,
    superAdmin: user.super_admin,
  };
};