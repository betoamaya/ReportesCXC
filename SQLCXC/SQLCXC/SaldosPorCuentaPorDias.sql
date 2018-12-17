/* Alta Varibles*/
DECLARE @sEmpresa AS CHAR(5),
        @dInicio AS DATE,
        @dFin AS DATE,
        @sCliente AS VARCHAR(10) = NULL;

DECLARE @RelacionMov AS TABLE
(
    Mov VARCHAR(30),
    CtaContable VARCHAR(15)
);

DECLARE @Corte AS TABLE
(
    CtaContable VARCHAR(15),
    Descripcion VARCHAR(100),
    Saldo MONEY,
    Mov CHAR(20),
    MovID VARCHAR(20),
    FechaEmision DATETIME,
    Cliente CHAR(10),
    Nombre VARCHAR(100),
    Dias INT
);

DECLARE @RelacionXML AS XML,
        @sEstacion AS INT,
        @dFechaD AS DATETIME,
        @dFechaA AS DATETIME,
        @dFechaFinMes AS DATETIME;

/***********************************/
SELECT @sEmpresa = 'TUN',
       @dInicio = '2010-01-01',
       @dFin = '2018-11-01',
       @sCliente = NULL;
/***********************************/

SET @RelacionXML
    = CAST('<RelacionMov>
			<fila Mov="Bol Pas Credito" CtaContable="101-010-102" />
			<fila Mov="CFDI SIN VIAJE GRAV" CtaContable="101-010-312" />
			<fila Mov="FACT PAQ Anticipada" CtaContable="101-010-302" />
			<fila Mov="FACT PAQ Contrato" CtaContable="101-010-302" />
			<fila Mov="FACT PAQ FXC" CtaContable="101-010-303" />
			<fila Mov="Fact Pas Credito" CtaContable="101-010-311" />
			<fila Mov="FACT.VE.GRAVADO" CtaContable="101-010-312" />
			<fila Mov="Factura TranspInd" CtaContable="101-010-301" />
			<fila Mov="FACTURA VE TOTAL" CtaContable="101-010-312" />
			<fila Mov="Ing Diverso Credito" CtaContable="101-015-300" />
			<fila Mov="Int Vta AF" CtaContable="101-020-300" />
			<fila Mov="Otros Ingresos" CtaContable="101-020-300" />
			<fila Mov="Prestamo" CtaContable="101-015-106" />
			<fila Mov="SI Contra Recibo" CtaContable="101-015-300" />
			<fila Mov="SI Documento" CtaContable="101-020-300" />
			<fila Mov="Venta  Activos Fijos" CtaContable="101-020-300" />
		</RelacionMov>' AS XML);

SELECT @dFechaD = CONVERT(VARCHAR, @dInicio, 101) + ' 00:00:00',
       @dFechaA = CONVERT(VARCHAR, @dFin, 101) + ' 23:59:59',
       @dFechaFinMes = DATEADD(dd, - (DAY(DATEADD(mm, 1, @dFin))), DATEADD(mm, 1, @dFin)),
       @sEstacion = (CASE @sEmpresa
                         WHEN 'TUN' THEN
                             10000
                         WHEN 'TSL' THEN
                             10001
                         WHEN 'PROMO' THEN
                             10002
                         ELSE
                             10005
                     END
                    );

INSERT INTO @RelacionMov
(
    Mov,
    CtaContable
)
SELECT T.LOC.value('@Mov', 'VARCHAR(30)') AS Mov,
       T.LOC.value('@CtaContable', 'VARCHAR(15)') AS CtaContable
FROM @RelacionXML.nodes('//RelacionMov/fila') AS T(LOC);

/*Primer Fase*/
INSERT INTO @Corte
(
    CtaContable,
    Descripcion,
    Saldo,
    Mov,
    MovID,
    FechaEmision,
    Cliente,
    Nombre,
    Dias
)
SELECT rm.CtaContable,
       cta.Descripcion,
       vac.Saldo,
       cxc.Mov,
       cxc.MovID,
       cxc.FechaEmision,
       cxc.Cliente,
       cte.Nombre,
       DATEDIFF(DAY, cxc.FechaEmision, @dFechaFinMes) AS Dias
FROM dbo.VerAuxCorte AS vac
    INNER JOIN @RelacionMov AS rm
        ON vac.Mov = rm.Mov
    INNER JOIN dbo.Cxc AS cxc
        ON vac.ModuloID = cxc.ID
           AND vac.MovID = cxc.MovID
    INNER JOIN dbo.Cte AS cte
        ON vac.Cuenta = cte.Cliente
    LEFT JOIN dbo.Cta AS cta
        ON cta.Cuenta = rm.CtaContable
WHERE vac.Estacion = @sEstacion
      AND vac.Empresa = @sEmpresa
      AND vac.Saldo > 0.9999;
/*****CASO Fact Pas Sedena - Lumx Pas Credito*****/
INSERT INTO @Corte
(
    CtaContable,
    Descripcion,
    Saldo,
    Mov,
    MovID,
    FechaEmision,
    Cliente,
    Nombre,
    Dias
)
SELECT cod.Cuenta AS CtaContable,
       cta.Descripcion,
       cod.Debe AS Saldo,
       cxc.Mov,
       cxc.MovID,
       cxc.FechaEmision,
       cxc.Cliente,
       cte.Nombre,
       DATEDIFF(DAY, cxc.FechaEmision, @dFechaFinMes) AS Dias
FROM dbo.VerAuxCorte AS vac
    INNER JOIN dbo.Cxc AS cxc
        ON vac.ModuloID = cxc.ID
           AND vac.MovID = cxc.MovID
    INNER JOIN dbo.Cte AS cte
        ON vac.Cuenta = cte.Cliente
    INNER JOIN dbo.Venta AS v
        ON v.Mov = cxc.Origen
           AND v.MovID = cxc.OrigenID
    INNER JOIN dbo.Cont AS con
        ON v.ContID = con.ID
    INNER JOIN dbo.ContD AS cod
        ON con.ID = cod.ID
           AND ISNULL(cod.Haber, 0) = 0
    LEFT JOIN dbo.Cta AS cta
        ON cta.Cuenta = cod.Cuenta
WHERE vac.Estacion = @sEstacion
      AND vac.Empresa = @sEmpresa
      AND vac.Mov IN ( 'Fact Pas Sedena', 'Lumx Pas Credito' )
      AND vac.Saldo > 0.9999
UNION ALL
SELECT cta.Cuenta AS CtaContable,
       cta.Descripcion,
       -cxcd.Importe AS Saldo,
       vac.Mov,
       vac.MovID,
       cxc2.FechaEmision,
       cxc2.Cliente,
       cte.Nombre,
       DATEDIFF(DAY, cxc2.FechaEmision, @dFechaFinMes) AS Dias
FROM dbo.VerAuxCorte AS vac
    INNER JOIN dbo.Cxc AS cxc2
        ON vac.Mov = cxc2.Mov
           AND vac.MovID = cxc2.MovID
    INNER JOIN dbo.Cte AS cte
        ON cxc2.Cliente = cte.Cliente
    INNER JOIN dbo.CxcD AS cxcd
        ON vac.Mov = cxcd.Aplica
           AND vac.MovID = cxcd.AplicaID
    INNER JOIN dbo.Cxc AS cxc
        ON cxcd.ID = cxc.ID
           AND cxc.Estatus = 'CONCLUIDO'
           AND cxc.FechaEmision <= @dFechaFinMes
    INNER JOIN dbo.Concepto AS ccp
        ON cxc.Concepto = ccp.Concepto
           AND ISNULL(cxc.OrigenTipo, 'CXC') = ccp.Modulo
    INNER JOIN dbo.Cta AS cta
        ON ccp.Cuenta = cta.Cuenta
WHERE vac.Estacion = @sEstacion
      AND vac.Empresa = @sEmpresa
      AND vac.Mov IN ( 'Fact Pas Sedena', 'Lumx Pas Credito' )
      AND vac.Saldo > 0.9999;
/******CASO NOTA CARGO - SI Contra Recibo Pas**********/
INSERT INTO @Corte
(
    CtaContable,
    Descripcion,
    Saldo,
    Mov,
    MovID,
    FechaEmision,
    Cliente,
    Nombre,
    Dias
)
SELECT cod.Cuenta AS CtaContable,
       cta.Descripcion,
       cod.Debe AS Saldo,
       cxc.Mov,
       cxc.MovID,
       cxc.FechaEmision,
       cxc.Cliente,
       cte.Nombre,
       DATEDIFF(DAY, cxc.FechaEmision, @dFechaFinMes) AS Dias
FROM dbo.VerAuxCorte AS vac
    INNER JOIN dbo.Cxc AS cxc
        ON vac.ModuloID = cxc.ID
           AND vac.MovID = cxc.MovID
    INNER JOIN dbo.Cte AS cte
        ON vac.Cuenta = cte.Cliente
    INNER JOIN dbo.Cont AS con
        ON cxc.ContID = con.ID
    INNER JOIN dbo.ContD AS cod
        ON con.ID = cod.ID
           AND ISNULL(cod.Haber, 0) = 0
    LEFT JOIN dbo.Cta AS cta
        ON cta.Cuenta = cod.Cuenta
WHERE vac.Estacion = @sEstacion
      AND vac.Empresa = @sEmpresa
      AND vac.Mov IN ( 'Nota Cargo', 'SI Contra Recibo Pas' )
      AND vac.Saldo > 0.9999;
--SELECT *
--FROM @Corte AS c;

SELECT c.CtaContable,
       c.Descripcion,
       c.Cliente,
       c.Nombre,
       c.Mov,
       c.MovID,
       SUM(c.Saldo) AS Saldo,
       SUM(   CASE
                  WHEN DATEDIFF(DAY, c.FechaEmision, @dFechaFinMes)
                       BETWEEN 0 AND 29 THEN
                      c.Saldo
                  ELSE
                      0
              END
          ) AS 'Saldo Al Corriente',
       SUM(   CASE
                  WHEN DATEDIFF(DAY, c.FechaEmision, @dFechaFinMes)
                       BETWEEN 30 AND 59 THEN
                      c.Saldo
                  ELSE
                      0
              END
          ) AS 'Saldo +30',
       SUM(   CASE
                  WHEN DATEDIFF(DAY, c.FechaEmision, @dFechaFinMes)
                       BETWEEN 60 AND 89 THEN
                      c.Saldo
                  ELSE
                      0
              END
          ) AS 'Saldo +60',
       SUM(   CASE
                  WHEN DATEDIFF(DAY, c.FechaEmision, @dFechaFinMes) >= 90 THEN
                      c.Saldo
                  ELSE
                      0
              END
          ) AS 'Saldo +90'
FROM @Corte AS c
--WHERE c.CtaContable = '101-010-311'
--      AND c.Mov = 'Lumx Pas Credito'
GROUP BY c.CtaContable,
         c.Descripcion,
         c.Cliente,
         c.Nombre,
         c.Mov,
         c.MovID
ORDER BY c.CtaContable, c.Cliente, c.MovID;

/*TOTALES*/

SELECT c.CtaContable,
       c.Descripcion,
       FORMAT(SUM(c.Saldo), 'C', 'en-us') AS Saldo,
       SUM(   CASE
                  WHEN DATEDIFF(DAY, c.FechaEmision, @dFechaFinMes)
                       BETWEEN 0 AND 29 THEN
                      c.Saldo
                  ELSE
                      0
              END
          ) AS 'Saldo Al Corriente',
       SUM(   CASE
                  WHEN DATEDIFF(DAY, c.FechaEmision, @dFechaFinMes)
                       BETWEEN 30 AND 59 THEN
                      c.Saldo
                  ELSE
                      0
              END
          ) AS 'Saldo +30',
       SUM(   CASE
                  WHEN DATEDIFF(DAY, c.FechaEmision, @dFechaFinMes)
                       BETWEEN 60 AND 89 THEN
                      c.Saldo
                  ELSE
                      0
              END
          ) AS 'Saldo +60',
       SUM(   CASE
                  WHEN DATEDIFF(DAY, c.FechaEmision, @dFechaFinMes) >= 90 THEN
                      c.Saldo
                  ELSE
                      0
              END
          ) AS 'Saldo +90'
FROM @Corte AS c
--WHERE c.CtaContable = '101-010-311'
--      AND c.Mov = 'Fact Pas Sedena'
GROUP BY c.CtaContable,
         c.Descripcion
ORDER BY c.CtaContable;

