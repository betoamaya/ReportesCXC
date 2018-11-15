

/* Generando información para el reporte*/
EXEC dbo.spVerAuxCorte @Estacion = 10000,      -- int
                       @Empresa = 'TUN',       -- char(5)
                       @Modulo = 'CXC',        -- char(5)
                       @FechaD = '2010-01-01', -- datetime
                       @FechaA = '2018-11-30', -- datetime
                       @CuentaD = '00000',     -- char(10)
                       @CuentaA = 'TUN';       -- char(10)

/*Consulta reporte*/
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
       Cxc.Sucursal
FROM VerAuxCorte
    LEFT OUTER JOIN Cxc
        ON VerAuxCorte.ModuloID = Cxc.ID
    JOIN Cte
        ON VerAuxCorte.Cuenta = Cte.Cliente
WHERE VerAuxCorte.Estacion = 10000
      AND VerAuxCorte.Empresa = 'TUN'
      AND Cxc.Mov NOT IN ( 'Solicitud Deposito', 'Redondeo', 'CFD Anticipo', 'Ing de Empleado Cred',
                           'CFD Anticipo ServCom', 'Factura Ant AF SI', 'Factura Anticipos VE', 'Factura Anticipo AF'
                         )
      AND VerAuxCorte.Saldo > 0.9999
--AND Cte.Cliente = ISNULL(@sCliente, Cte.Cliente)
ORDER BY Cte.Cliente,
         VerAuxCorte.Mov,
         Cxc.FechaEmision DESC;