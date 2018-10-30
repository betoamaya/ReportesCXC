SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
GO
-- =============================================
-- Responsable:		Roberto Amaya
-- Ultimo Cambio:	03/04/2018
-- Descripción:		Reporte de Saldo de Clientes
-- =============================================
CREATE PROCEDURE [dbo].[repSaldoClientes]
    @sEmpresa AS CHAR(5) ,
    @dInicio AS DATE ,
    @dFin AS DATE ,
    @sCliente AS VARCHAR(10) = NULL
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;
        DECLARE @sEstacion AS INT ,
            @dFechaD AS DATETIME ,
            @dFechaA AS DATETIME ,
            @sClienteD AS CHAR(10) ,
            @sClienteA AS CHAR(10);
        SELECT  @dFechaD = CONVERT(VARCHAR, @dInicio, 101) + ' 00:00:00' ,
                @dFechaA = CONVERT(VARCHAR, @dFin, 101) + ' 23:59:59' ,
                @sEstacion = ( CASE @sEmpresa
                                 WHEN 'TUN' THEN 10000
                                 WHEN 'TSL' THEN 10001
                                 WHEN 'PROMO' THEN 10002
                                 ELSE 10005
                               END )

        SELECT  @sClienteD = MIN(Cliente) ,
                @sClienteA = MAX(Cliente)
        FROM    dbo.Cte
		
        EXEC dbo.spVerAuxCorte @Estacion = @sEstacion, -- int
            @Empresa = @sEmpresa, -- char(5)
            @Modulo = 'CXC', -- char(5)
            @FechaD = @dFechaD, -- datetime
            @FechaA = @dFechaA, -- datetime
            @CuentaD = @sClienteD, -- char(10)
            @CuentaA = @sClienteA; -- char(10)
	
        SELECT  VerAuxCorte.Moneda ,
                VerAuxCorte.Cuenta ,
                VerAuxCorte.Mov ,
                VerAuxCorte.MovID ,
                VerAuxCorte.Saldo ,
                Cxc.FechaEmision ,
                Cxc.Referencia ,
                Cxc.Vencimiento ,
                Cte.Cliente ,
                Cte.Nombre
        FROM    VerAuxCorte
                LEFT OUTER JOIN Cxc ON VerAuxCorte.ModuloID = Cxc.ID
                JOIN Cte ON VerAuxCorte.Cuenta = Cte.Cliente
        WHERE   VerAuxCorte.Estacion = @sEstacion
                AND VerAuxCorte.Empresa = @sEmpresa
                AND Cxc.Mov NOT IN ( 'Solicitud Deposito', 'Redondeo', 'CFD Anticipo', 'Ing de Empleado Cred',
                                     'CFD Anticipo ServCom' )
                AND Cte.Cliente = ISNULL(@sCliente, Cte.Cliente)
        ORDER BY Cte.Cliente ,
                VerAuxCorte.Mov ,
                Cxc.FechaEmision DESC 
    END

GO
