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
       Cfd.UUID,                       /*2018-12-07 -> Se Agrego Fecha XML por Solicitud de la C.P. Zoraida*/
       c.Cuenta,
       c2.Descripcion,
       DATEDIFF(DAY, Cxc.FechaEmision, '2018-11-30') AS dias
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
    LEFT JOIN dbo.Concepto AS c
        ON c.Concepto = Cxc.Concepto
           AND (CASE
                    WHEN ISNULL(Cxc.OrigenTipo, '') = '' THEN
                        'CXC'
                    WHEN Cxc.Mov = 'Int Vta AF' THEN
                        'CXC'
                    ELSE
                        Cxc.OrigenTipo
                END
               ) = c.Modulo
    LEFT JOIN dbo.Cta AS c2
        ON c2.Cuenta = c.Cuenta
WHERE vac.Estacion = 10000
      AND vac.Empresa = 'tun'
      AND vac.Mov NOT IN (   'Solicitud Deposito', 'Redondeo', 'CFD Anticipo', 'Ing de Empleado Cred',
                             'CFD Anticipo ServCom', 'Factura Ant AF SI', 'Factura Anticipos VE',
                             'Factura Anticipo AF', /*RAAM-15/11/2018 - Se Agrego mas movimientos de la C.P. Zoraida*/
                             'Int Dev x Cob Banco', 'Saldo a Favor' /*RAAM-12/12/2018 - C.P. Solicito quitar estos movimientos*/
                         )
      AND vac.Saldo > 0.9999 /*RAAM-15/11/2018 - Se Agrego filtro para descartar saldo menor a un peso de la C.P. Zoraida*/
      --AND dbo.VerAuxCorte.MovID = 'TPAS637974'
      AND (
              Cxc.MovID IN ( '153', '154', '42', '2016-667', '155', '148' )
              AND Cxc.Mov = 'Prestamo' AND vac.Estacion = 10000
          )
      OR (
             Cxc.MovID IN ( 'TOT226937' )
             AND Cxc.Mov = 'Int Vta AF' AND vac.Estacion = 10000
         )
      OR (
             Cxc.MovID IN ( 'LVE5210' )
             AND Cxc.Mov = 'FACT.VE.GRAVADO' AND vac.Estacion = 10000
         )
      OR (
             Cxc.MovID IN ( 'UPAS87181', 'UPAS87175' )
             AND Cxc.Mov = 'Bol Pas Credito' AND vac.Estacion = 10000
         )
      OR (
             Cxc.MovID IN ( 'TOT96621', 'TOT96663', 'TOT96665', 'TOT96669' )
             AND Cxc.Mov = 'NOTA CARGO' AND vac.Estacion = 10000
         )
	OR (
             Cxc.MovID IN ( 'TPAS655028' )
             AND Cxc.Mov = 'FACT PAS CREDITO' AND vac.Estacion = 10000
         )


---AND Cte.Cliente= '23629'
ORDER BY Cte.Cliente,
         vac.Mov,
         Cxc.FechaEmision DESC;

/***************************************************/
SELECT c.OrigenTipo, * FROM dbo.Cxc AS c WHERE c.MovID = 'TPAS655028'
SELECT * FROM dbo.Concepto AS c WHERE c.Concepto = 'DEUDORES AJENOS'

/******************************/
SELECT * FROM cxc WHERE cxc.MovID in ('TOT226937') AND cxc.Mov = 'Int Vta AF'
SELECT * FROM dbo.Concepto AS c WHERE c.Concepto = 'INTERESES LP GRAV 15%'

/******************************/
SELECT * FROM dbo.Cxc WHERE cxc.MovID = 'LVE5210' AND Mov = 'FACT.VE.GRAVADO'
SELECT * FROM dbo.Concepto AS c WHERE c.Concepto like 'VIAJE ESPECIAL GRAVA%'


/****************************/

SELECT *  FROM cxc WHERE Cxc.MovID IN ( 'UPAS87181', 'UPAS87175' )
             AND Cxc.Mov = 'Bol Pas Credito'
SELECT * FROM dbo.Concepto AS c WHERE c.Concepto = 'PASAJES CONTADO BOLETERA'
SELECT * FROM dbo.Concepto AS c WHERE c.Cuenta = '101-010-102'

/*********************/
SELECT *  FROM cxc WHERE Cxc.MovID IN ( 'TPAS655028' )
             AND Cxc.Mov = 'Fact Pas Credito'
SELECT * FROM dbo.Concepto AS c WHERE c.Cuenta = '101-015-311'
SELECT * FROM dbo.Cta AS c WHERE c.Cuenta = '101-015-311'
