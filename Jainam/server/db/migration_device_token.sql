-- migration_device_token.sql
-- Run this once against your existing database.
--
-- Why: fingerprint_hash (from the free FingerprintJS build) is not
-- guaranteed unique. Two students with identical phone model + OS +
-- browser version can and do produce the exact same hash. Since the
-- gate scan (/api/entry/scan) is unauthenticated kiosk mode, the hash
-- was the ONLY thing identifying who scanned — a collision meant one
-- student's scans silently landed on the other student's account.
--
-- Fix: give every approved device its own server-generated random
-- token (real entropy, can never collide) at approval time. The scan
-- endpoint now looks up by this token instead of the fingerprint hash.
-- fingerprint_hash is kept purely as an audit trail / duplicate-hash
-- warning signal for the admin.

ALTER TABLE `devices`
  ADD COLUMN `device_token` VARCHAR(64) DEFAULT NULL AFTER `fingerprint_hash`;

ALTER TABLE `devices`
  ADD UNIQUE KEY `uniq_device_token` (`device_token`);

-- Backfill: every device that's already approved needs a token too,
-- since previously nothing was generated for them.
UPDATE `devices`
SET `device_token` = SHA2(CONCAT(id, '-', UUID(), '-', RAND(), '-', NOW(6)), 256)
WHERE `is_active` = TRUE AND `device_token` IS NULL;
