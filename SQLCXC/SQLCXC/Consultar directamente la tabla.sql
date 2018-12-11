SELECT c.Ejercicio,
       c.Periodo,
       *
FROM dbo.CFD AS c
WHERE c.MovID = '154';

SELECT c.Ejercicio,
       c.Periodo,
       c.Saldo,
       *
FROM dbo.Cxc AS c
WHERE c.MovID = '154';

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


/*******************************************************************************************************************************/
GO
SELECT *
FROM VerAuxCorte
WHERE Estacion = 10000
      AND Empresa = 'tun'
      AND Mov NOT IN ( 'Solicitud Deposito', 'Redondeo', 'CFD Anticipo', 'Ing de Empleado Cred',
                       'CFD Anticipo ServCom', 'Factura Ant AF SI', 'Factura Anticipos VE', 'Factura Anticipo AF' /*RAAM-15/11/2018 - Se Agrego mas movimientos de la C.P. Zoraida*/
                     )
      AND Saldo > 0.9999;

SELECT vac.Moneda,
       vac.Cuenta,
       vac.Mov,
       vac.MovID,
       vac.Saldo,
       Cxc.FechaEmision,
       Cxc.Referencia,
       Cxc.Vencimiento,
       Cte.Cliente,
       Cte.Nombre,
       Cxc.ClienteEnviarA AS Sucursal, /*2018-10-31 -> Se Agrego Sucursal por Solicitud de la C.P. Zoraida*/
       Cfd.FechaTimbrado,              /*2018-10-30 -> Se Agrego Fecha XML por Solicitud de la C.P. Zoraida*/
       Cfd.UUID                        /*2018-12-07 -> Se Agrego Fecha XML por Solicitud de la C.P. Zoraida*/
FROM dbo.VerAuxCorte AS vac
    LEFT OUTER JOIN Cxc
        ON vac.ModuloID = Cxc.ID
    LEFT JOIN dbo.Venta AS vtas
        ON vtas.MovID = vac.MovID
           AND vtas.Mov = vac.Mov
    LEFT JOIN dbo.CFD AS Cfd
        ON Cxc.MovID = Cfd.MovID
           AND (CASE
                    WHEN ISNULL(Cxc.OrigenTipo, 'CXC') = 'CXC' THEN
                        Cxc.ID
                    WHEN Cxc.OrigenTipo = 'VTAS' THEN
                        vtas.ID
                END
               ) = Cfd.ModuloID
    JOIN Cte
        ON vac.Cuenta = Cte.Cliente
WHERE vac.Estacion = 10000
      AND vac.Empresa = 'tun'
      AND vac.Mov NOT IN ( 'Solicitud Deposito', 'Redondeo', 'CFD Anticipo', 'Ing de Empleado Cred',
                           'CFD Anticipo ServCom', 'Factura Ant AF SI', 'Factura Anticipos VE', 'Factura Anticipo AF' /*RAAM-15/11/2018 - Se Agrego mas movimientos de la C.P. Zoraida*/
                         )
      AND vac.Saldo > 0.9999 /*RAAM-15/11/2018 - Se Agrego filtro para descartar saldo menor a un peso de la C.P. Zoraida*/
--AND dbo.VerAuxCorte.MovID = 'TPAS637974'
ORDER BY Cte.Cliente,
         vac.Mov,
         Cxc.FechaEmision DESC;


/**************************************************************/

--2140

SELECT vac.Moneda,
       vac.Cuenta,
       vac.Mov,
       vac.MovID,
       vac.Saldo,
       Cxc.FechaEmision,
       Cxc.Referencia,
       Cxc.Vencimiento,
       Cte.Cliente,
       Cte.Nombre,
       Cxc.ClienteEnviarA AS Sucursal, /*2018-10-31 -> Se Agrego Sucursal por Solicitud de la C.P. Zoraida*/
       Cfd.FechaTimbrado,              /*2018-10-30 -> Se Agrego Fecha XML por Solicitud de la C.P. Zoraida*/
       Cfd.UUID,                        /*2018-12-07 -> Se Agrego Fecha XML por Solicitud de la C.P. Zoraida*/
	   c.Cuenta,
	   c2.Descripcion,
	   datediff(day, Cxc.FechaEmision, '2018-11-30') AS dias
FROM dbo.VerAuxCorte AS vac
    LEFT OUTER JOIN Cxc
        ON vac.ModuloID = Cxc.ID
    LEFT JOIN dbo.Venta AS vtas
        ON vtas.MovID = vac.MovID
           AND vtas.Mov = vac.Mov
    LEFT JOIN dbo.CFD AS Cfd
        ON Cxc.MovID = Cfd.MovID
           AND (CASE
                    WHEN ISNULL(Cxc.OrigenTipo, 'CXC') = 'CXC' THEN
                        Cxc.ID
                    WHEN Cxc.OrigenTipo = 'VTAS' THEN
                        vtas.ID
                END
               ) = Cfd.ModuloID
    JOIN Cte
        ON vac.Cuenta = Cte.Cliente
	left JOIN dbo.Concepto AS c ON c.Concepto = Cxc.Concepto AND c.Modulo = 'VTAS'
	LEFT JOIN dbo.Cta AS c2 ON c2.Cuenta = c.Cuenta
WHERE vac.Estacion = 10000
      AND vac.Empresa = 'tun'
      AND vac.Mov NOT IN ( 'Solicitud Deposito', 'Redondeo', 'CFD Anticipo', 'Ing de Empleado Cred',
                           'CFD Anticipo ServCom', 'Factura Ant AF SI', 'Factura Anticipos VE', 'Factura Anticipo AF' /*RAAM-15/11/2018 - Se Agrego mas movimientos de la C.P. Zoraida*/
                         )
      AND vac.Saldo > 0.9999 /*RAAM-15/11/2018 - Se Agrego filtro para descartar saldo menor a un peso de la C.P. Zoraida*/
--AND dbo.VerAuxCorte.MovID = 'TPAS637974'
ORDER BY Cte.Cliente,
         vac.Mov,
         Cxc.FechaEmision DESC;
