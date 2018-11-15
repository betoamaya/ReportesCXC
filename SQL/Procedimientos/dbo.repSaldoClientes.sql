SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
-- =============================================
-- Responsable:		Roberto Amaya
-- Ultimo Cambio:	15/11/2018
-- Descripción:		Reporte de Saldo de Clientes
-- =============================================
ALTER PROCEDURE [dbo].[repSaldoClientes]
    @sEmpresa AS CHAR(5),
    @dInicio AS DATE,
    @dFin AS DATE,
    @sCliente AS VARCHAR(10) = NULL
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
    DECLARE @sEstacion AS INT,
            @dFechaD AS DATETIME,
            @dFechaA AS DATETIME,
            @sClienteD AS CHAR(10),
            @sClienteA AS CHAR(10);
    SELECT @dFechaD = CONVERT(VARCHAR, @dInicio, 101) + ' 00:00:00',
           @dFechaA = CONVERT(VARCHAR, @dFin, 101) + ' 23:59:59',
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

    SELECT @sClienteD = MIN(Cliente),
           @sClienteA = MAX(Cliente)
    FROM dbo.Cte;

    EXEC dbo.spVerAuxCorte @Estacion = @sEstacion, -- int
                           @Empresa = @sEmpresa,   -- char(5)
                           @Modulo = 'CXC',        -- char(5)
                           @FechaD = @dFechaD,     -- datetime
                           @FechaA = @dFechaA,     -- datetime
                           @CuentaD = @sClienteD,  -- char(10)
                           @CuentaA = @sClienteA;  -- char(10)

    SELECT VerAuxCorte.Moneda,
           VerAuxCorte.Cuenta,
           VerAuxCorte.Mov,
           VerAuxCorte.MovID,
           VerAuxCorte.Saldo,
           Cxc.FechaEmision,
           Cxc.Referencia,
           Cxc.Vencimiento,
           Cte.Cliente,
           Cte.Nombre,
           Cxc.ClienteEnviarA, /*2018-10-30 -> Se Agrego Sucursal por Solicitud de la C.P. Zoraida*/
           Cfd.FechaTimbrado   /*2018-10-30 -> Se Agrego Fecha XML por Solicitud de la C.P. Zoraida*/
    FROM VerAuxCorte
        LEFT OUTER JOIN Cxc
            ON VerAuxCorte.ModuloID = Cxc.ID
        LEFT JOIN dbo.CFD AS Cfd
            ON Cxc.MovID = Cfd.MovID
               AND Cfd.Ejercicio = Cxc.Ejercicio
               AND Cfd.Periodo = Cxc.Periodo
        JOIN Cte
            ON VerAuxCorte.Cuenta = Cte.Cliente
    WHERE VerAuxCorte.Estacion = @sEstacion
          AND VerAuxCorte.Empresa = @sEmpresa
          AND Cxc.Mov NOT IN ( 'Solicitud Deposito', 'Redondeo', 'CFD Anticipo', 'Ing de Empleado Cred',
                               'CFD Anticipo ServCom', 'Factura Ant AF SI', 'Factura Anticipos VE',
                               'Factura Anticipo AF' /*RAAM-15/11/2018 - Se Agrego mas movimientos de la C.P. Zoraida*/
                             )
          AND VerAuxCorte.Saldo > 0.9999 /*RAAM-15/11/2018 - Se Agrego filtro para descartar saldo menor a un peso de la C.P. Zoraida*/
          AND Cte.Cliente = ISNULL(@sCliente, Cte.Cliente)
    ORDER BY Cte.Cliente,
             VerAuxCorte.Mov,
             Cxc.FechaEmision DESC;
END;
GO
