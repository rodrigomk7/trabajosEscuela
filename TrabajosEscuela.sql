-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema parcial_2018
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS `p2018` ;

-- -----------------------------------------------------
-- Schema parcial_2018
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `p2018` DEFAULT CHARACTER SET utf8 ;
USE `p2018` ;

-- -----------------------------------------------------
-- Table `Personas`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Personas` ;

CREATE TABLE IF NOT EXISTS `Personas` (
  `dni` INTEGER NOT NULL,
  `Apellidos` VARCHAR(40) NOT NULL,
  `Nombres` VARCHAR(40) NOT NULL,
  PRIMARY KEY (`dni`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Cargos`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Cargos` ;

CREATE TABLE IF NOT EXISTS `Cargos` (
  `idCargo` INTEGER NOT NULL,
  `Cargo` VARCHAR(20) NOT NULL,
  PRIMARY KEY (`idCargo`),
  UNIQUE (`cargo`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Profesores`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Profesores` ;

CREATE TABLE IF NOT EXISTS `Profesores` (
  `dni` INTEGER NOT NULL,
  `idCargo` INTEGER NOT NULL,
  PRIMARY KEY (`dni`,`idCargo`),
  CONSTRAINT `fk_table1_Personas`
    FOREIGN KEY (`dni`)
    REFERENCES `Personas` (`dni`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Profesores_Cargos1`
    FOREIGN KEY (`idCargo`)
    REFERENCES `Cargos` (`idCargo`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_Profesores_Cargos1_idx` ON `Profesores` (`idCargo` ) ;


-- -----------------------------------------------------
-- Table `Alumnos`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Alumnos` ;

CREATE TABLE IF NOT EXISTS `Alumnos` (
  `dni` INTEGER NOT NULL,
  `cx` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`dni`),
  UNIQUE (`cx`),
  CONSTRAINT `fk_Alumnos_Personas1`
    FOREIGN KEY (`dni`)
    REFERENCES `Personas` (`dni`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE UNIQUE INDEX `cx_UNIQUE` ON `Alumnos` (`cx` ) ;


-- -----------------------------------------------------
-- Table `Trabajos`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Trabajos` ;

CREATE TABLE IF NOT EXISTS `Trabajos` (
  `idTrabajo` INTEGER NOT NULL,
  `Titulo` VARCHAR(100) NOT NULL,
  `duracion` INTEGER NOT NULL DEFAULT 6,
`area` VARCHAR(10) NULL,
--  `area` ENUM('Hardware', 'Redes', 'Software') NOT NULL,
  `fechaPresentacion` DATE NULL,
  `fechaAprobacion` DATE NOT NULL,
  `fechaFinalizacion` DATE NULL,
  PRIMARY KEY (`idTrabajo`))
ENGINE = InnoDB;

CREATE UNIQUE INDEX `Titulo_UNIQUE` ON `Trabajos` (`Titulo` ) ;


-- -----------------------------------------------------
-- Table `RolesEnTrabajo`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `RolesEnTrabajos` ;

CREATE TABLE IF NOT EXISTS `RolesEnTrabajos` (
  `idTrabajo` INTEGER NOT NULL,
  `dni` INTEGER NOT NULL,
  `rol` VARCHAR(7) NOT NULL,
  `desde` DATE NOT NULL,
  `hasta` DATE NULL,
  `razon` VARCHAR(100) NULL,
  PRIMARY KEY (`idTrabajo`, `dni`),
  CONSTRAINT `fk_Trabajos_has_Profesores_Trabajos1`
    FOREIGN KEY (`idTrabajo`)
    REFERENCES `Trabajos` (`idTrabajo`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Trabajos_has_Profesores_Profesores1`
    FOREIGN KEY (`dni`)
    REFERENCES `Profesores` (`dni`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
    CONSTRAINT CHECK (rol in ('Tutor','Cotutor','Jurado')))
ENGINE = InnoDB;

CREATE INDEX `fk_Trabajos_has_Profesores_Profesores1_idx` ON `RolesEnTrabajos` (`dni` ) ;

CREATE INDEX `fk_Trabajos_has_Profesores_Trabajos1_idx` ON `RolesEnTrabajos` (`idTrabajo` ) ;


-- -----------------------------------------------------
-- Table `AlumnosEnTrabajos`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `AlumnosEnTrabajos` ;

CREATE TABLE IF NOT EXISTS `AlumnosEnTrabajos` (
  `idTrabajo` INTEGER NOT NULL,
  `dni` INTEGER NOT NULL,
  `desde` DATE NOT NULL,
  `hasta` DATE NULL,
  `razon` VARCHAR(100) NULL,
  PRIMARY KEY (`idTrabajo`, `dni`),
  CONSTRAINT `fk_Trabajos_has_Alumnos_Trabajos1`
    FOREIGN KEY (`idTrabajo`)
    REFERENCES `Trabajos` (`idTrabajo`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Trabajos_has_Alumnos_Alumnos1`
    FOREIGN KEY (`dni`)
    REFERENCES `Alumnos` (`dni`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_Trabajos_has_Alumnos_Alumnos1_idx` ON `AlumnosEnTrabajos` (`dni` ) ;

CREATE INDEX `fk_Trabajos_has_Alumnos_Trabajos1_idx` ON `AlumnosEnTrabajos` (`idTrabajo` ) ;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

-- restricciones 
ALTER TABLE `Trabajos`
ADD CONSTRAINT CHECK (area IN ('Hardware', 'Redes', 'Software') ) ;


/* 2. Crear un procedimiento llamado DetalleRoles, que reciba un rango de años y que muestre:

 Año, DNI, Apellidos, Nombres, Tutor, Cotutor y Jurado, donde Tutor, Cotutor y Jurado muestran
 la cantidad de trabajos en los que un profesor participó en un trabajo con ese rol entre el rango de fechas especificado.
 
 El listado se mostrará ordenado por año, apellidos, nombres y DNI (se pueden emplear vistas u otras estructuras para lograr
 la funcionalidad solicitada. Para obtener el año de una fecha se puede emplear la función YEAR()*/ 

DROP PROCEDURE IF EXISTS DetalleRoles;

-- Definicion del procedimiento
DELIMITER //
CREATE PROCEDURE DetalleRoles(IN pDesde year, pHasta year, out mensaje varchar(100) )

SALIR:BEGIN
	declare aux year;
     
	IF (pDesde IS NULL)  or (pHasta is null)THEN
		SET mensaje= 'Error en los datos de busqueda';
        LEAVE SALIR;
        
	elseif (pDesde > pHasta) then
		set aux=pDesde;
		set pDesde=pHasta;
		set pHasta=aux;   
    end if;
    
-- tabla final a presentar     
DROP TEMPORARY TABLE IF EXISTS Resultado;
 CREATE TEMPORARY TABLE Resultado (	`Anio` YEAR , `DNI` INTEGER,`Apellidos` VARCHAR(45) ,`Nombres` VARCHAR(45) , `Tutor`INT DEFAULT 0, `Cotutor` INT DEFAULT 0, `Jurado` INT DEFAULT 0);

-- Inserto en Resultado informacion de tutor
INSERT INTO Resultado (Anio, DNI, Apellidos ,Nombres ,Tutor)
	SELECT  YEAR(RET.desde) as 'Anio' ,P.dni 	AS 'DNI', P.apellidos AS 'Apellidos', P.nombres AS 'Nombres', COUNT( RET.rol) AS 'Tutor' FROM
	( Personas AS P  INNER JOIN Profesores AS PR ON P.dni = Pr.dni) 
    INNER JOIN RolesEnTrabajos AS RET ON RET.dni = PR.dni
	WHERE RET.rol = 'Tutor'
	GROUP BY YEAR(RET.desde) ,P.dni , P.apellidos , P.nombres
	ORDER BY P.dni;
    
-- Inserto en Resultado informacion de cotutor
INSERT INTO Resultado (Anio, DNI,Apellidos ,Nombres ,Cotutor)
	SELECT  YEAR(RET.desde) as 'Anio' ,P.dni 	AS 'DNI', P.apellidos AS 'Apellidos', P.nombres AS 'Nombres', COUNT( RET. rol) AS 'Cotutor' FROM
	( Personas AS P  INNER JOIN Profesores AS PR
	ON P.dni = Pr.dni) INNER JOIN RolesEnTrabajos AS RET
	ON RET.dni = PR.dni
	WHERE RET.rol = 'Cotutor'
	GROUP BY YEAR(RET.desde) ,P.dni , P.apellidos , P.nombres
	ORDER BY P.dni;
    
 -- Inserto en Resultado informacion de tutor
 INSERT INTO Resultado (Anio, DNI,Apellidos ,Nombres ,Jurado)
	SELECT  YEAR(RET.desde) as 'Anio' ,P.dni 	AS 'DNI', P.apellidos AS 'Apellidos', P.nombres AS 'Nombres', COUNT( RET. rol) AS 'Jurado' FROM
	( Personas AS P  INNER JOIN Profesores AS PR
	ON P.dni = Pr.dni) INNER JOIN RolesEnTrabajos AS RET
	ON RET.dni = PR.dni
	WHERE RET.rol = 'Jurado'
	GROUP BY YEAR(RET.desde) ,P.dni , P.apellidos , P.nombres
	ORDER BY P.dni;
    
    
-- Consulta de acuerdo a los parametros de entrada
	SELECT Anio , DNI ,Apellidos , Nombres, SUM(Tutor) AS 'Tutos', SUM(Cotutor) AS 'Cotutor' , SUM(Jurado) AS 'Jurado'
	FROM Resultado 
	WHERE Anio BETWEEN pDesde AND pHasta
	GROUP BY Anio, DNI, Apellidos , Nombres
	ORDER BY Anio, Apellidos, Nombres, DNI;
    
	SET mensaje = 'Operacion realizada con exito';
			
END //
DELIMITER ;

-- Prueba
CALL DetalleRoles (2010,2017,@resultado);
SELECT @resultado;

--  ---------------------------------------------------------------------------------------------------------------------------------

/* 3. Crear un procedimiento almacenado llamado NuevoTrabajo, para que agregue un trabajo nuevo. 

El procedimiento deberá efectuar las comprobaciones necesarias (incluyendo que la fecha de aprobación sea igual o mayor a la de presentación) 
y devolver los mensajes correspondientes (uno por cada condición de error, y otro por el éxito) [15].*/

DROP PROCEDURE IF EXISTS NuevoTrabajo;

-- Definicion del procedimiento
DELIMITER //
CREATE PROCEDURE NuevoTrabajo(IN  pidTrabajo INTEGER, pTitulo VARCHAR(100), pduracion INTEGER, parea VARCHAR(10) ,
  pfechaPresentacion DATE,pfechaAprobacion DATE , pfechaFinalizacion DATE, out mensaje varchar(45) )

-- Crea un empleado siempre y cuando: no exista otros empleado con el mismo dni e id y los datos ingresados sean validos

SALIR: BEGIN  
		IF ( pidTrabajo IS NULL) OR  (pTitulo IS NULL) OR (pduracion IS NULL) OR (parea IS NULL) 
        OR (pfechaPresentacion IS NULL) OR (pfechaAprobacion IS NULL) THEN
		SET mensaje = 'Error en los datos de entrada';
        LEAVE SALIR;
        
	ELSEIF EXISTS (SELECT * FROM Trabajos WHERE idTrabajo = pidTrabajo) THEN
		SET mensaje = 'Ya existe un Trabajo con ese id';
        LEAVE SALIR;
        
	ELSEIF EXISTS (SELECT * FROM Trabajos WHERE Titulo = pTitulo) THEN
		SET mensaje = 'Ya existe un  Trabajo con ese titulo';
        LEAVE SALIR;
        
	ELSEIF pduracion<=0 THEN 
		SET mensaje = 'Error en la duracion del trabajo';
        LEAVE SALIR;
        
	ELSEIF parea != 'Hardware' AND parea != 'Redes' AND parea != 'Software' THEN 
		SET mensaje = 'La area ingresada  es no valida';
        LEAVE SALIR;
        
	ELSEIF pFechaAprobacion < pfechaPresentacion THEN 
		SET mensaje = 'La fecha de aprobacion es menor a la  de presentacion';
        LEAVE SALIR; 
        
    ELSE
		START TRANSACTION;
			INSERT INTO `Trabajos` ( idTrabajo , Titulo, duracion, area, fechaPresentacion,fechaAprobacion, fechaFinalizacion)  
            VALUES ( pidTrabajo , pTitulo, pduracion, parea, pfechaPresentacion,pfechaAprobacion, pfechaFinalizacion);

            SET mensaje = 'El trabajo se creo con éxito';
		COMMIT;		
    END IF;
END //
DELIMITER ;

CALL NuevoTrabajo(11, 'Sistema Primaria de Salud (CAPS)', 7, 'Software', '2017-11-29', '2018-11-29', NULL, @resultado);
SELECT @resultado;

select * from trabajos;


/*4. Realizar un trigger, llamado AuditarTrabajos, 
para que cuando se agregue un trabajo con una duración superior a los 12 meses, o inferior a 3 meses, 
registre en una tabla de auditoría los detalles del trabajo (todos los campos de la tabla Trabajos), el usuario que lo agregó y la fecha en la que lo hizo [15].*/


-- Definicion del trigger
DROP TRIGGER IF EXISTS `Trig_Trabajos_Insercion`;

DELIMITER //
CREATE TRIGGER `Trig_Trabajos_Insercion` 
AFTER INSERT ON `Trabajos` FOR EACH ROW
BEGIN

IF ((new.duracion < 3) or (new.duracion >12 ) ) then
	INSERT INTO AuditarTrabajos VALUES (
		DEFAULT, 
		NEW.idTrabajo,
		NEW.titulo, 
        NEW.duracion,
        New.area,
        NEW.fechaPresentacion,
        NEW.fechaAprobacion,
        NEW.fechaFinalizacion,
		'I', 
		SUBSTRING_INDEX(USER(), '@', 1), 
		SUBSTRING_INDEX(USER(), '@', -1), 
		NOW()
  );
  end if;
END //
DELIMITER ;

call NuevoTrabajo(101,"Redes 12345",16,"Software",'2019-09-01','2020-01-01',null,@resultado);
select @resultado;

delete from Trabajos where idTrabajo = 101;
INSERT INTO Trabajos VALUE (101,"Redes 12345",2,"Software",'2019-09-01','2020-01-01',null);


select * from AuditarTrabajos;
delete from AuditarTrabajos;


