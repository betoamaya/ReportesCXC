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
       Cxc.ClienteEnviarA AS 'Sucursal'
       ,Cfd.FechaTimbrado, cfd.Modulo
FROM VerAuxCorte
    LEFT OUTER JOIN Cxc
        ON VerAuxCorte.ModuloID = Cxc.ID
    left JOIN dbo.CFD AS Cfd
        ON Cxc.MovID = Cfd.MovID --AND Cfd.Ejercicio = Cxc.Ejercicio AND Cfd.Periodo = Cxc.Periodo --AND Cfd.Modulo = VerAuxCorte.Modulo
    LEFT JOIN Cte
        ON VerAuxCorte.Cuenta = Cte.Cliente
WHERE VerAuxCorte.Estacion = 10000
      AND VerAuxCorte.Empresa = 'TUN'
      AND Cxc.Mov NOT IN ( 'Solicitud Deposito', 'Redondeo', 'CFD Anticipo', 'Ing de Empleado Cred',
                           'CFD Anticipo ServCom'
                         )
AND Cte.Cliente = ISNULL('490', Cte.Cliente)
ORDER BY Cte.Cliente,
         VerAuxCorte.Mov,
         Cxc.FechaEmision DESC;

SELECT * FROM dbo.CFD AS c WHERE c.MovID = '371'

SELECT *
FROM dbo.VerAuxCorte AS vac
    LEFT OUTER JOIN Cxc
        ON vac.ModuloID = Cxc.ID
WHERE vac.Estacion = 10001;

SELECT MIN(c.Cliente),
       MAX(c.Cliente)
FROM dbo.Cte AS c;


EXEC dbo.spVerAuxCorte @Estacion = 10001,      -- int
                       @Empresa = 'TSL',       -- char(5)
                       @Modulo = 'CXC',        -- char(5)
                       @FechaD = '2018-10-01', -- datetime
                       @FechaA = '2018-10-30', -- datetime
                       @CuentaD = '00000',     -- char(10)
                       @CuentaA = 'TUN';       -- char(10)


