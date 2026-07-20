-- Multi-role chat: admin ↔ teacher ↔ parent

ALTER TABLE `conversations`
  ADD COLUMN `kind` ENUM('teacher_parent', 'admin_teacher', 'admin_parent') NOT NULL DEFAULT 'teacher_parent' AFTER `id`,
  ADD COLUMN `admin_user_id` INT NULL AFTER `parent_id`;

ALTER TABLE `conversations`
  MODIFY `teacher_id` INT NULL,
  MODIFY `parent_id` INT NULL,
  MODIFY `student_id` INT NULL;

ALTER TABLE `conversations`
  ADD INDEX `conversations_kind_idx`(`kind`),
  ADD INDEX `conversations_admin_user_id_idx`(`admin_user_id`);

ALTER TABLE `conversations`
  ADD CONSTRAINT `conversations_admin_user_id_fkey`
    FOREIGN KEY (`admin_user_id`) REFERENCES `users`(`id`) ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE `conversations`
  ADD CONSTRAINT `conversations_student_id_fkey`
    FOREIGN KEY (`student_id`) REFERENCES `students`(`id`) ON DELETE SET NULL ON UPDATE CASCADE;
