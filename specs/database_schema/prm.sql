-- MySQL Script generated by MySQL Workbench
-- Wed Apr 12 17:04:09 2017
-- Model: New Model    Version: 1.0
-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUT‌ION';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `mydb` DEFAULT CHARACTER SET utf8 ;
USE `mydb` ;

-- -----------------------------------------------------
-- Table `mydb`.`legal_entity`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`legal_entity` (
  `id` VARCHAR(36) NOT NULL,
  `name` TEXT NOT NULL,
  `short_name` TEXT NULL,
  `type` ENUM('msp', 'mis', 'drug_store') NOT NULL,
  `edrpou` CHAR(8) NOT NULL,
  `addresses[]` JSON NOT NULL,
  `phones[]` JSON NULL,
  `email` VARCHAR(255) NULL,
  `created_at` DATETIME NOT NULL,
  `inserted_by` TEXT NOT NULL,
  `updated_at` DATETIME NULL,
  `updated_by` TEXT NULL,
  `is_active` BOOLEAN NOT NULL,
  `public_name` VARCHAR(45) NULL,
  `kveds` JSON NOT NULL,
  `status` ENUM('new', 'verified') NOT NULL,
  `owner_property_type` ENUM('state', 'private') NOT NULL,
  `legal_form` ENUM('ТОВ', 'ФОП') NOT NULL COMMENT 'ТОВ\nФОП\nАТ\n',
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`doctor`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`doctor` (
  `id` VARCHAR(36) NOT NULL,
  `education[]` JSON NOT NULL,
  `qualification[]` JSON NULL COMMENT '### Qualification\n+ type (enum, required)\n    - Інтернатура\n    - Спеціалізація\n    - Передатестаційний цикл\n    - Тематичне вдосконалення\n    - Курси інформації\n    - Стажування\n+ institution_name: Академія Богомольця (string, required)\n+ speciality: Педіатр (string, required)\n+ issued_date: 2017-02-28 (string, required)',
  `speciality[]` ENUM('терапевт', 'педіатр', 'сімейний лікар') NOT NULL,
  `professional_level` JSON NOT NULL COMMENT '### ProfessionalLevel\n+ degree (enum, required)\n    - Друга категорія\n    - Перша категорія\n    - Вища категорія\n+ qualification_type (enum, required)\n    - Присвоєння\n    - Підтвердження\n+ institution_name: Академія Богомольця (string, required)\n+ issued_date: 2017-02-28 (string, required)',
  `science_degree` JSON NULL COMMENT '   - Доктор філософії\n    - Доктор наук',
  `academic_degree` JSON NULL COMMENT '    - Старший дослідник\n    - Доцент\n    - Професор',
  `specialization` TEXT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`party`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`party` (
  `id` VARCHAR(36) NOT NULL,
  `last_name` TEXT NOT NULL,
  `first_name` TEXT NOT NULL,
  `second_name` TEXT NULL,
  `birth_date` DATE NOT NULL,
  `gender` ENUM('GENDER') NOT NULL,
  `tax_id` TEXT NULL,
  `documents` JSON NULL,
  `phones` JSON NULL,
  `created_at` DATETIME NOT NULL,
  `inserted_by` TEXT NOT NULL,
  `updated_at` DATETIME NOT NULL,
  `updated_by` TEXT NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_Party_doctor1`
    FOREIGN KEY (`id`)
    REFERENCES `mydb`.`doctor` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`division`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`division` (
  `id` VARCHAR(36) NOT NULL,
  `legal_entity_id` VARCHAR(36) NOT NULL,
  `name` VARCHAR(45) NOT NULL,
  `address` JSON NOT NULL,
  `external_id` TEXT NULL,
  `phones[]` JSON NOT NULL,
  `email` VARCHAR(255) NULL,
  `mountain_group` VARCHAR(255) NULL,
  `type` VARCHAR(255) NOT NULL,
  `is_active` BOOLEAN NOT NULL,
  INDEX `fk_division_msp1_idx` (`legal_entity_id` ASC),
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_division_msp1`
    FOREIGN KEY (`legal_entity_id`)
    REFERENCES `mydb`.`legal_entity` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`employee`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`employee` (
  `id` VARCHAR(36) NOT NULL,
  `legal_entity_id` TEXT NOT NULL,
  `position` JSON NOT NULL COMMENT 'посада',
  `start_date` DATETIME NOT NULL,
  `end_date` DATETIME NULL,
  `is_active` BOOLEAN NOT NULL,
  `created_at` TIMESTAMP NOT NULL,
  `updated_at` TIMESTAMP NOT NULL,
  `inserted_by` TEXT NOT NULL,
  `updated_by` TEXT NOT NULL,
  `status` ENUM('') NOT NULL,
  `employee_type` ENUM('doctor', 'hr', 'owner', 'accountant') NOT NULL,
  `party_id` TEXT NOT NULL,
  `division_id` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_Labour_Contract_MSP1_idx` (`legal_entity_id` ASC),
  INDEX `fk_employee_Party1_idx` (`party_id` ASC),
  INDEX `fk_employee_division1_idx` (`division_id` ASC),
  CONSTRAINT `fk_Labour_Contract_MSP1`
    FOREIGN KEY (`legal_entity_id`)
    REFERENCES `mydb`.`legal_entity` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_employee_Party1`
    FOREIGN KEY (`party_id`)
    REFERENCES `mydb`.`party` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_employee_division1`
    FOREIGN KEY (`division_id`)
    REFERENCES `mydb`.`division` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`declaration_signed`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`declaration_signed` (
  `id` VARCHAR(36) NOT NULL,
  `document_type` ENUM('declaration', 'msp_registration') NOT NULL,
  `document` JSON NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`declaration`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`declaration` (
  `id` VARCHAR(36) NOT NULL,
  `patient_id` TEXT NOT NULL,
  `start_date` DATETIME NOT NULL,
  `end_date` DATETIME NOT NULL,
  `status` ENUM('') NOT NULL,
  `signed_at` DATETIME NOT NULL,
  `created_at` DATETIME NOT NULL,
  `inserted_by` TEXT NOT NULL,
  `updated_at` DATETIME NOT NULL,
  `updated_by` TEXT NOT NULL,
  `is_active` BOOLEAN NULL,
  `scope` ENUM('') NOT NULL,
  `employee_id` TEXT NOT NULL,
  `division_id` VARCHAR(36) NOT NULL,
  `legal_entity_id` VARCHAR(36) NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_declaration_employee1_idx` (`employee_id` ASC, `id` ASC),
  CONSTRAINT `fk_declaration_employee1`
    FOREIGN KEY (`employee_id` , `id`)
    REFERENCES `mydb`.`employee` (`id` , `id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_declaration_declaration_signed1`
    FOREIGN KEY ()
    REFERENCES `mydb`.`declaration_signed` ()
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`product`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`product` (
  `id` VARCHAR(36) NOT NULL,
  `name` TEXT NOT NULL,
  `parameters[]` JSON NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`capitation_contract`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`capitation_contract` (
  `id` VARCHAR(36) NOT NULL,
  `msp_id` TEXT NOT NULL,
  `product_id` TEXT NOT NULL,
  `start_date` DATETIME NOT NULL,
  `end_date` DATETIME NULL,
  `status` ENUM('') NOT NULL,
  `signed_at` DATETIME NULL,
  `services[]` JSON NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_GPMD_Contract_MSP1_idx` (`msp_id` ASC),
  INDEX `fk_GPMD_Contract_Product1_idx` (`product_id` ASC),
  CONSTRAINT `fk_GPMD_Contract_MSP1`
    FOREIGN KEY (`msp_id`)
    REFERENCES `mydb`.`legal_entity` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_GPMD_Contract_Product1`
    FOREIGN KEY (`product_id`)
    REFERENCES `mydb`.`product` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`table2`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`table2` (
)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`phone`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`phone` (
  `id` INT NOT NULL,
  `party_id` INT NOT NULL,
  `type` ENUM('PHONE_TYPE') NOT NULL,
  `number` TEXT NOT NULL,
  `created_at` DATETIME NOT NULL,
  `inserted_by` TEXT NOT NULL,
  `modified_at` DATETIME NOT NULL,
  `modified_by` TEXT NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`files`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`files` (
  `id` INT NOT NULL,
  `party_id` INT NOT NULL,
  `type` ENUM('FILE_TYPE') NULL DEFAULT NULL,
  `content` TEXT NULL DEFAULT NULL,
  `created_at` DATETIME NOT NULL,
  `inserted_by` TEXT NOT NULL,
  `modified_at` DATETIME NOT NULL,
  `modified_by` TEXT NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`phone_hstr`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`phone_hstr` (
  `id` INT NOT NULL,
  `phone_id` INT NOT NULL,
  `party_id` INT NOT NULL,
  `type` ENUM('PHONE_TYPE') NOT NULL,
  `number` TEXT NOT NULL,
  `created_at` DATETIME NOT NULL,
  `inserted_by` TEXT NOT NULL,
  `modified_at` DATETIME NOT NULL,
  `modified_by` TEXT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_phone_hstr_phone1_idx` (`phone_id` ASC),
  CONSTRAINT `fk_phone_hstr_phone1`
    FOREIGN KEY (`phone_id`)
    REFERENCES `mydb`.`phone` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`party_hstr`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`party_hstr` (
  `id` INT NOT NULL,
  `party_id` INT NOT NULL,
  `mpi_id` TEXT NOT NULL,
  `last_name` TEXT NOT NULL,
  `first_name` TEXT NOT NULL,
  `second_name` TEXT NULL DEFAULT NULL,
  `birth_date` DATE NOT NULL,
  `gender` ENUM('GENDER') NOT NULL,
  `email` VARCHAR(255) NULL DEFAULT NULL,
  `tax_id` TEXT NULL DEFAULT NULL,
  `national_id` TEXT NULL DEFAULT NULL,
  `death_date` DATE NULL DEFAULT NULL,
  `state` ENUM('STATE') NOT NULL,
  `state_reason` TEXT NULL DEFAULT NULL,
  `created_at` DATETIME NOT NULL,
  `inserted_by` TEXT NOT NULL,
  `modified_at` DATETIME NOT NULL,
  `modified_by` TEXT NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`document`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`document` (
  `id` INT NOT NULL,
  `party_id` INT NOT NULL,
  `document` JSON NOT NULL,
  `created_at` DATETIME NOT NULL,
  `inserted_by` TEXT NOT NULL,
  `modified_at` DATETIME NOT NULL,
  `modified_by` TEXT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_document_party_idx` (`party_id` ASC),
  CONSTRAINT `fk_document_party`
    FOREIGN KEY (`party_id`)
    REFERENCES `mydb`.`doctor` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`address`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`address` (
  `id` INT NOT NULL,
  `party_id` INT NOT NULL,
  `address` JSON NOT NULL,
  `created_at` DATETIME NOT NULL,
  `inserted_by` TEXT NOT NULL,
  `modified_at` DATETIME NOT NULL,
  `modified_by` TEXT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_address_party1_idx` (`party_id` ASC),
  CONSTRAINT `fk_address_party1`
    FOREIGN KEY (`party_id`)
    REFERENCES `mydb`.`doctor` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`phone1`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`phone1` (
  `id` INT NOT NULL,
  `party_id` INT NOT NULL,
  `type` ENUM('PHONE_TYPE') NOT NULL,
  `number` TEXT NOT NULL,
  `created_at` DATETIME NOT NULL,
  `inserted_by` TEXT NOT NULL,
  `modified_at` DATETIME NOT NULL,
  `modified_by` TEXT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_phone_party1_idx` (`party_id` ASC),
  CONSTRAINT `fk_phone_party1`
    FOREIGN KEY (`party_id`)
    REFERENCES `mydb`.`doctor` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`files1`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`files1` (
  `id` INT NOT NULL,
  `party_id` INT NOT NULL,
  `type` ENUM('FILE_TYPE') NULL,
  `content` TEXT NULL,
  `created_at` DATETIME NOT NULL,
  `inserted_by` TEXT NOT NULL,
  `modified_at` DATETIME NOT NULL,
  `modified_by` TEXT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_files_party1_idx` (`party_id` ASC),
  CONSTRAINT `fk_files_party1`
    FOREIGN KEY (`party_id`)
    REFERENCES `mydb`.`doctor` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`document_hstr`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`document_hstr` (
  `id` INT NOT NULL,
  `document_id` INT NOT NULL,
  `party_id` INT NOT NULL,
  `document` JSON NOT NULL,
  `created_at` DATETIME NOT NULL,
  `inserted_by` TEXT NOT NULL,
  `modified_at` DATETIME NOT NULL,
  `modified_by` TEXT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_document_hstr_document1_idx` (`document_id` ASC),
  CONSTRAINT `fk_document_hstr_document1`
    FOREIGN KEY (`document_id`)
    REFERENCES `mydb`.`document` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`address_hstr`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`address_hstr` (
  `id` INT NOT NULL,
  `address_id` INT NOT NULL,
  `party_id` INT NOT NULL,
  `address` JSON NOT NULL,
  `created_at` DATETIME NOT NULL,
  `inserted_by` TEXT NOT NULL,
  `modified_at` DATETIME NOT NULL,
  `modified_by` TEXT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_address_hstr_address1_idx` (`address_id` ASC),
  CONSTRAINT `fk_address_hstr_address1`
    FOREIGN KEY (`address_id`)
    REFERENCES `mydb`.`address` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`phone_hstr1`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`phone_hstr1` (
  `id` INT NOT NULL,
  `phone_id` INT NOT NULL,
  `party_id` INT NOT NULL,
  `type` ENUM('PHONE_TYPE') NOT NULL,
  `number` TEXT NOT NULL,
  `created_at` DATETIME NOT NULL,
  `inserted_by` TEXT NOT NULL,
  `modified_at` DATETIME NOT NULL,
  `modified_by` TEXT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_phone_hstr_phone1_idx` (`phone_id` ASC),
  CONSTRAINT `fk_phone_hstr_phone1`
    FOREIGN KEY (`phone_id`)
    REFERENCES `mydb`.`phone1` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`party_hstr1`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`party_hstr1` (
  `id` INT NOT NULL,
  `party_id` INT NOT NULL,
  `mpi_id` TEXT NOT NULL,
  `last_name` TEXT NOT NULL,
  `first_name` TEXT NOT NULL,
  `second_name` TEXT NULL,
  `birth_date` DATE NOT NULL,
  `gender` ENUM('GENDER') NOT NULL,
  `email` VARCHAR(255) NULL,
  `tax_id` TEXT NULL,
  `national_id` TEXT NULL,
  `death_date` DATE NULL,
  `state` ENUM('STATE') NOT NULL,
  `state_reason` TEXT NULL,
  `created_at` DATETIME NOT NULL,
  `inserted_by` TEXT NOT NULL,
  `modified_at` DATETIME NOT NULL,
  `modified_by` TEXT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_party_hstr_party1_idx` (`party_id` ASC),
  CONSTRAINT `fk_party_hstr_party1`
    FOREIGN KEY (`party_id`)
    REFERENCES `mydb`.`doctor` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`person_hstr`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`person_hstr` (
  `id` TEXT NOT NULL,
  `person_id` TEXT NOT NULL,
  `version` TEXT NOT NULL,
  `last_name` TEXT NOT NULL,
  `first_name` TEXT NOT NULL,
  `second_name` TEXT NULL,
  `former_last_name` TEXT NULL,
  `birth_date` DATE NOT NULL,
  `birth_place` TEXT NULL,
  `gender` ENUM('GENDER') NOT NULL,
  `email` VARCHAR(255) NULL,
  `tax_id` TEXT NULL,
  `national_id` TEXT NULL,
  `death_date` DATE NULL,
  `is_active` BOOLEAN NOT NULL,
  `documents` JSON NULL,
  `addresses` JSON NULL,
  `phones` JSON NULL,
  `history` JSON NULL,
  `signature` TEXT NOT NULL,
  `inserted_at` DATETIME NOT NULL,
  `inserted_by` TEXT NOT NULL,
  `updated_at` DATETIME NOT NULL,
  `updated_by` TEXT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_person_hstr_person1_idx` (`person_id` ASC),
  CONSTRAINT `fk_person_hstr_person1`
    FOREIGN KEY (`person_id`)
    REFERENCES `mydb`.`doctor` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`users`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`users` (
  `id` VARCHAR(36) NOT NULL,
  `email` VARCHAR(255) NOT NULL,
  `user_name` VARCHAR(45) NOT NULL,
  `inserted_at` DATETIME NOT NULL,
  `inserted_by` TEXT NULL,
  `updated_at` DATETIME NOT NULL,
  `updated_by` TEXT NOT NULL,
  `status` ENUM('ACTIVE', 'CLOSED') NOT NULL,
  `credentials` JSON NOT NULL,
  `party_id` VARCHAR(26) NULL,
  `scopes[]` TEXT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_users_party1_idx` (`party_id` ASC),
  CONSTRAINT `fk_users_party1`
    FOREIGN KEY (`party_id`)
    REFERENCES `mydb`.`party` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`registration_request`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`registration_request` (
  `id` VARCHAR(36) NOT NULL,
  `msp_id` VARCHAR(45) NULL,
  `creator_id` VARCHAR(45) NOT NULL,
  `data` JSON NOT NULL,
  `email` VARCHAR(255) NOT NULL,
  `creator_signature` TEXT NOT NULL,
  `status` ENUM('') NOT NULL,
  `verification_id` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`declaration_request`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`declaration_request` (
  `id` VARCHAR(36) NOT NULL,
  `creator_id` TEXT NOT NULL,
  `data` JSON NOT NULL,
  `TS` TIMESTAMP NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`msp`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`msp` (
  `id` VARCHAR(36) NOT NULL,
  `accreditation` JSON NOT NULL,
  `license[]` JSON NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_msp_legal_entity1`
    FOREIGN KEY (`id`)
    REFERENCES `mydb`.`legal_entity` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`employee_doctor`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`employee_doctor` (
  `id` VARCHAR(36) NOT NULL,
  `education[]` JSON NOT NULL,
  `qualification[]` JSON NULL COMMENT '### Qualification\n+ type (enum, required)\n    - Інтернатура\n    - Спеціалізація\n    - Передатестаційний цикл\n    - Тематичне вдосконалення\n    - Курси інформації\n    - Стажування\n+ institution_name: Академія Богомольця (string, required)\n+ speciality: Педіатр (string, required)\n+ issued_date: 2017-02-28 (string, required)',
  `specialities[]` JSON NOT NULL,
  `science_degree` JSON NULL COMMENT '   - Доктор філософії\n    - Доктор наук',
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_employee_doctor_employee1`
    FOREIGN KEY (`id`)
    REFERENCES `mydb`.`employee` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`log_changes`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`log_changes` (
  `id` VARCHAR(36) NOT NULL,
  `user_id` VARCHAR(45) NOT NULL COMMENT 'who_changed',
  `resource` TEXT NOT NULL COMMENT 'legal_entity, employee, declaration, etc.\n',
  `what_changed` JSON NOT NULL,
  `TS` TIMESTAMP NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`employee_requests`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`employee_requests` (
  `id` INT NOT NULL,
  `data` JSON NOT NULL COMMENT 'Employee request body',
  `TS` TIMESTAMP NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`geo_data???`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`geo_data???` (
)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`ukr_med_registry`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`ukr_med_registry` (
  `ID` VARCHAR(36) NOT NULL,
  `edrpou` VARCHAR(45) NOT NULL,
  `name` TEXT NOT NULL,
  PRIMARY KEY (`ID`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`declaration_log_changes`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`declaration_log_changes` (
  `id` VARCHAR(36) NOT NULL,
  `user_id` VARCHAR(45) NOT NULL COMMENT 'who_changed',
  `resource` TEXT NOT NULL COMMENT 'legal_entity, employee, declaration, etc.\n',
  `what_changed` JSON NOT NULL,
  `TS` TIMESTAMP NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
