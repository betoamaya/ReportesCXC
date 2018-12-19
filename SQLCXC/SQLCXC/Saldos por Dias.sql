
--SELECT vac.Moneda,
--       vac.Cuenta,
--       vac.Mov,
--       vac.MovID,
--       vac.Saldo,
--       Cxc.FechaEmision,
--       Cxc.Referencia,
--       Cxc.Vencimiento,
--       Cte.Cliente,
--       Cte.Nombre,
--       Cxc.ClienteEnviarA AS Sucursal, /*2018-10-31 -> Se Agrego Sucursal por Solicitud de la C.P. Zoraida*/
--       Cfd.FechaTimbrado,              /*2018-10-30 -> Se Agrego Fecha XML por Solicitud de la C.P. Zoraida*/
--       Cfd.UUID,                       /*2018-12-07 -> Se Agrego Fecha XML por Solicitud de la C.P. Zoraida*/
--       c.Cuenta,
--       c2.Descripcion,
--       DATEDIFF(DAY, Cxc.FechaEmision, '2018-11-30') AS dias

SELECT tmp.Cuenta,
       c3.Descripcion,
       tmp.Cliente,
       Cte.Nombre,
       SUM(tmp.Saldo) AS 'Saldo',
       SUM(tmp.[Saldo al Corriente]) AS 'Saldo al Corriente',
       SUM(tmp.[Saldo + 30]) AS 'Saldo + 30',
       SUM(tmp.[Saldo + 60]) AS 'Saldo + 60',
       SUM(tmp.[Saldo + 90]) AS 'Saldo + 90'
FROM
(
    SELECT Cte.Cliente,
           c.Cuenta,
           vac.MovID,
           SUM(vac.Saldo) AS Saldo,
           SUM(   CASE
                      WHEN DATEDIFF(DAY, Cxc.FechaEmision, '2018-11-30')
                           BETWEEN 0 AND 29 THEN
                          vac.Saldo
                      ELSE
                          0
                  END
              ) AS 'Saldo al Corriente',
           SUM(   CASE
                      WHEN DATEDIFF(DAY, Cxc.FechaEmision, '2018-11-30')
                           BETWEEN 30 AND 59 THEN
                          vac.Saldo
                      ELSE
                          0
                  END
              ) AS 'Saldo + 30',
           SUM(   CASE
                      WHEN DATEDIFF(DAY, Cxc.FechaEmision, '2018-11-30')
                           BETWEEN 60 AND 89 THEN
                          vac.Saldo
                      ELSE
                          0
                  END
              ) AS 'Saldo + 60',
           SUM(   CASE
                      WHEN DATEDIFF(DAY, Cxc.FechaEmision, '2018-11-30') >= 90 THEN
                          vac.Saldo
                      ELSE
                          0
                  END
              ) AS 'Saldo + 90'
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
                                 'Int Dev x Cob Banco', 'Saldo a Favor'
                             )
          AND vac.Saldo > 0.9999 /*RAAM-15/11/2018 - Se Agrego filtro para descartar saldo menor a un peso de la C.P. Zoraida*/
    --AND dbo.VerAuxCorte.MovID = 'TPAS637974'
    --AND (
    --        Cxc.MovID IN ( '153', '154', '42', '2016-667', '155', '148' )
    --        AND Cxc.Mov = 'Prestamo'
    --    )
    --OR (
    --       Cxc.MovID IN ( 'TOT226937' )
    --       AND Cxc.Mov = 'Int Vta AF'
    --   )
    --OR (
    --       Cxc.MovID IN ( 'LVE5210' )
    --       AND Cxc.Mov = 'FACT.VE.GRAVADO'
    --   )
    --OR (
    --       Cxc.MovID IN ( 'UPAS87181', 'UPAS87175' )
    --       AND Cxc.Mov = 'Bol Pas Credito'
    --   )
    --OR (
    --       Cxc.MovID IN ( 'TOT96621', 'TOT96663', 'TOT96665', 'TOT96669' )
    --       AND Cxc.Mov = 'NOTA CARGO'
    --       AND vac.Estacion = 10000
    --   )
    -- AND Cte.Cliente= '23629'     

    GROUP BY Cte.Cliente,
             c.Cuenta,
             vac.MovID
) AS tmp
    LEFT JOIN Cte
        ON tmp.Cliente = Cte.Cliente
    LEFT JOIN dbo.Cta AS c3
        ON tmp.Cuenta = c3.Cuenta
WHERE
	tmp.Cuenta = '101-010-102'
GROUP BY tmp.Cuenta,
         c3.Descripcion,
         tmp.Cliente,
         Cte.Nombre
ORDER BY tmp.Cuenta,
         tmp.Cliente ASC;

--ORDER BY Cte.Cliente,
--         vac.Mov,
--         Cxc.FechaEmision DESC;