-- =========================================================
-- AAAA_MM_DD_NN_<base>_<descripcion>.sql
-- Base:     acore_world | acore_characters | acore_auth
-- Qué hace: <una frase>
-- Autor:    <quien>
-- Fecha:    AAAA-MM-DD
--
-- ⚠ Si la base es acore_characters: BACKUP ANTES. Sin excepción.
-- =========================================================

-- --- Verificación previa (correr y anotar el número) --------------
-- SELECT COUNT(*) FROM `tabla` WHERE <mismo WHERE que el UPDATE/DELETE>;
-- Esperado: N filas

START TRANSACTION;

-- --- Cambios ------------------------------------------------------
-- Patrón idempotente: DELETE con WHERE exacto, después INSERT.

DELETE FROM `tabla` WHERE `clave` = 900001;
INSERT INTO `tabla` (`clave`, `campo`) VALUES (900001, 'valor');

COMMIT;

-- --- Verificación posterior ---------------------------------------
-- SELECT * FROM `tabla` WHERE `clave` = 900001;
-- Esperado: 1 fila con campo = 'valor'

-- --- Recargar en caliente -----------------------------------------
-- .reload tabla

-- --- ROLLBACK -----------------------------------------------------
-- DELETE FROM `tabla` WHERE `clave` = 900001;
-- (si era un UPDATE sobre una fila original, poné acá el UPDATE inverso
--  con los valores originales, copiados ANTES de ejecutar)
