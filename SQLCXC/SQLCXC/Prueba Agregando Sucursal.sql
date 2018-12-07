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
                           'CFD Anticipo ServCom'
                         )
--AND Cte.Cliente = ISNULL(@sCliente, Cte.Cliente)
ORDER BY Cte.Cliente,
         VerAuxCorte.Mov,
         Cxc.FechaEmision DESC;