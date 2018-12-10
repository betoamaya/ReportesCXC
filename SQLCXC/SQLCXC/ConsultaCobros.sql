/*Variables de envio*/
DECLARE @Empresa AS CHAR(3),
        @dInicio AS DATE,
        @dFin AS DATE,
        @Cliente AS VARCHAR(20) = NULL;

/*Datos que llevaran*/
SELECT @Empresa = 'TUN',
       @dInicio = '2018-12-01',
       @dFin = '2018-12-10',
       @Cliente = NULL;

/*Variables de Trabajo*/
DECLARE @Origen AS VARCHAR(50),
        @OrigenId VARCHAR(20),
        @dFechaD AS DATETIME,
        @dFechaA AS DATETIME;

SELECT @dFechaD = CONVERT(VARCHAR, @dInicio, 101) + ' 00:00:00',
       @dFechaA = CONVERT(VARCHAR, @dFin, 101) + ' 23:59:59';

/*Inicia Consulta de Cobros*/

SELECT