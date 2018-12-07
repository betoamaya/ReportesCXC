EXEC dbo.repSaldoClientes @sEmpresa = 'TUN',          -- char(5)
                          @dInicio = '2018-11-01', -- date
                          @dFin = '2018-11-30',    -- date
                          @sCliente = NULL           -- varchar(10)
