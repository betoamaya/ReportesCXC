EXEC dbo.repSaldoClientes @sEmpresa = 'TUN',          -- char(5)
                          @dInicio = '2010-01-01', -- date
                          @dFin = '2018-11-30',    -- date
                          @sCliente = NULL           -- varchar(10)
