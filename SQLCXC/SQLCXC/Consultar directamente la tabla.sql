SELECT *
FROM dbo.CFD AS c
WHERE c.MovID = 'TPAS665363';

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
       Cxc.ClienteEnviarA AS Sucursal, /*2018-10-31 -> Se Agrego Sucursal por Solicitud de la C.P. Zoraida*/
       Cfd.FechaTimbrado               /*2018-10-30 -> Se Agrego Fecha XML por Solicitud de la C.P. Zoraida*/
FROM VerAuxCorte
    LEFT OUTER JOIN Cxc
        ON VerAuxCorte.ModuloID = Cxc.ID
    LEFT JOIN dbo.CFD AS Cfd
        ON Cxc.MovID = Cfd.MovID
    --AND Cfd.Ejercicio = Cxc.Ejercicio
    --AND Cfd.Periodo = Cxc.Periodo
    JOIN Cte
        ON VerAuxCorte.Cuenta = Cte.Cliente
WHERE VerAuxCorte.Estacion = 10000
      AND VerAuxCorte.Empresa = 'tun'
      AND Cxc.Mov NOT IN ( 'Solicitud Deposito', 'Redondeo', 'CFD Anticipo', 'Ing de Empleado Cred',
                           'CFD Anticipo ServCom', 'Factura Ant AF SI', 'Factura Anticipos VE', 'Factura Anticipo AF' /*RAAM-15/11/2018 - Se Agrego mas movimientos de la C.P. Zoraida*/
                         )
      AND VerAuxCorte.Saldo > 0.9999 /*RAAM-15/11/2018 - Se Agrego filtro para descartar saldo menor a un peso de la C.P. Zoraida*/
      AND VerAuxCorte.MovID IN ( 'TPAS665501', 'TPAS665443', 'TPAS665450', 'TPAS665459', 'TPAS665462', 'TPAS665465',
                                 'TPAS665468', 'TPAS665470', 'TPAS665473', 'TPAS665477', 'TPAS665478', 'TPAS665494',
                                 'TPAS665499', 'TOT238418', 'TOT238423', 'TOT238424', 'TOT238425', 'TOT238426',
                                 'TOT238600', 'TOT238603', 'LPAS14034', 'LPAS14035', 'TPAS665345', 'TPAS665505',
                                 'TPAS665238', 'TOT238477', 'TPAS665237', '155', 'UVE19392', 'TPAS665510',
                                 'TPAS665512', 'TPAS664895', 'TPAS664899', 'TPAS665525', 'TPAS665555', 'TPAS664903',
                                 'TPAS664907', 'TPAS665558', 'TPAS665564', 'TOT238265'
                               )
ORDER BY Cte.Cliente,
         VerAuxCorte.Mov,
         Cxc.FechaEmision DESC;