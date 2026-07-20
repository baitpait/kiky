-- Add precise notification category (accuracy for Flutter UI)
ALTER TABLE `notifications`
  ADD COLUMN `category` ENUM(
    'attendance',
    'absence',
    'homework',
    'homework_confirm',
    'meal',
    'photo',
    'sticker',
    'live',
    'chat',
    'announcement'
  ) NOT NULL DEFAULT 'announcement' AFTER `body`;

-- Backfill legacy rows from title/body (same rules as Flutter fallback)
UPDATE `notifications` SET `category` = 'absence'
  WHERE `category` = 'announcement' AND (`title` LIKE '%غياب%' OR `body` LIKE '%غياب%');

UPDATE `notifications` SET `category` = 'attendance'
  WHERE `category` = 'announcement'
    AND (`title` LIKE '%حضور%' OR `body` LIKE '%حضور%' OR `title` LIKE '%انصراف%' OR `body` LIKE '%انصراف%');

UPDATE `notifications` SET `category` = 'homework_confirm'
  WHERE `category` = 'announcement'
    AND (`title` LIKE '%تأكيد%' AND (`title` LIKE '%واجب%' OR `body` LIKE '%واجب%'));

UPDATE `notifications` SET `category` = 'homework'
  WHERE `category` = 'announcement' AND (`title` LIKE '%واجب%' OR `body` LIKE '%واجب%');

UPDATE `notifications` SET `category` = 'meal'
  WHERE `category` = 'announcement'
    AND (`title` LIKE '%وجبة%' OR `body` LIKE '%وجبة%' OR `body` LIKE '%الفطور%' OR `body` LIKE '%الغداء%');

UPDATE `notifications` SET `category` = 'photo'
  WHERE `category` = 'announcement' AND (`title` LIKE '%صورة%' OR `body` LIKE '%صورة%');

UPDATE `notifications` SET `category` = 'sticker'
  WHERE `category` = 'announcement' AND (`title` LIKE '%ملصق%' OR `body` LIKE '%ملصق%');

UPDATE `notifications` SET `category` = 'live'
  WHERE `category` = 'announcement' AND (`title` LIKE '%بث%' OR `body` LIKE '%بث%');

UPDATE `notifications` SET `category` = 'chat'
  WHERE `category` = 'announcement'
    AND (`title` LIKE '%رسالة%' OR `body` LIKE '%رسالة%' OR `title` LIKE '%دردش%' OR `body` LIKE '%دردش%');

CREATE INDEX `notifications_user_id_category_idx` ON `notifications`(`user_id`, `category`);
