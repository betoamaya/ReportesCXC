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
			<fila Mov="Fact Pas Sedena" CtaContable="101-015-300" />
			<fila Mov="Fact Pas Sedena" CtaContable="101-010-311" />
			<fila Mov="FACT.VE.GRAVADO" CtaContable="101-010-312" />
			<fila Mov="Factura TranspInd" CtaContable="101-010-301" />
			<fila Mov="FACTURA VE TOTAL" CtaContable="101-010-312" />
			<fila Mov="Ing Diverso Credito" CtaContable="101-015-300" />
			<fila Mov="Int Vta AF" CtaContable="101-020-300" />
			<fila Mov="Lumx Pas Credito" CtaContable="101-010-102" />
			<fila Mov="Lumx Pas Credito" CtaContable="101-010-311" />
			<fila Mov="Otros Ingresos" CtaContable="101-020-300" />
			<fila Mov="Prestamo" CtaContable="101-015-106" />
			<fila Mov="SI Contra Recibo" CtaContable="101-015-300" />
			<fila Mov="SI Contra Recibo Pas" CtaContable="101-010-102" />
			<fila Mov="SI Contra Recibo Pas" CtaContable="101-010-311" />
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

/*Consulta*/

SELECT vac.Estacion,
       vac.ID,
       vac.Empresa,
       vac.Modulo,
       vac.Moneda,
       vac.Cuenta,
       vac.Mov,
       vac.MovID,
       vac.ModuloID,
       vac.Saldo
FROM dbo.VerAuxCorte AS vac
    INNER JOIN dbo.Cxc AS cxc
        ON vac.ModuloID = cxc.ID
           AND vac.MovID = cxc.MovID
    LEFT JOIN dbo.Venta AS v
        ON cxc.Origen = v.Mov
           AND cxc.OrigenID = v.MovID
    INNER JOIN dbo.ContD AS cd
        ON (CASE
                WHEN ISNULL(cxc.OrigenTipo, 'CXC') = 'CXC' THEN
                    cxc.ContID
                WHEN cxc.OrigenTipo = 'VTAS' THEN
                    v.ContID
            END
           ) = cd.ID
           AND ISNULL(cd.Haber, 0) = 0
WHERE vac.Empresa = @sEmpresa
      AND vac.Estacion = @sEstacion
      AND vac.Mov IN (
                         SELECT DISTINCT rm.Mov FROM @RelacionMov AS rm
                     );
