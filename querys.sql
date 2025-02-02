/*

### QUESTÃO 1
Esboce uma consulta SQL que retorne o código de todos os vendedores que
entre uma data DATA_INICIO e data DATA_FIM atendem aos seguintes requisitos:

A - Vendem QUANTIDADE de itens do produto de código PROD_1 maior que a
média de vendas por vendedor do produto de código PROD_1 em sua loja;

B - Vendem QUANTIDADE de itens do produto de código PROD_2 maior que a
média de vendas por vendedor do produto de código PROD_2 nas lojas com
mais de 1000 vendas do produto de código PROD_2 no período;

*/
/* CONSULTA A */
SELECT DISTINCT
    v.COD_VENDEDOR
FROM
    vendas v
    JOIN (
        SELECT
            COD_LOJA,
            AVG(QUANTIDADE) AS media_vendas
        FROM
            vendas
        WHERE
            COD_PRODUTO = 'PROD_1'
            AND DATA_VENDA BETWEEN DATA_INICIO AND DATA_FIM
        GROUP BY
            COD_LOJA
    ) mv ON v.COD_LOJA = mv.COD_LOJA
WHERE
    v.COD_PRODUTO = 'PROD_1'
    AND v.DATA_VENDA BETWEEN DATA_INICIO AND DATA_FIM
    AND v.QUANTIDADE > mv.media_vendas;

* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
/* CONSULTA B */
SELECT DISTINCT
    v.COD_VENDEDOR
FROM
    vendas v
    JOIN (
        -- Calcula a média de vendas por vendedor para o produto PROD_2 em lojas com mais de 1000 vendas do PROD_2 no período
        SELECT
            v1.COD_LOJA,
            AVG(v1.QUANTIDADE) AS media_vendas
        FROM
            vendas v1
        WHERE
            v1.COD_PRODUTO = 'PROD_2'
            AND v1.DATA_VENDA BETWEEN DATA_INICIO AND DATA_FIM
            AND v1.COD_LOJA IN (
                -- Seleciona apenas as lojas que venderam mais de 1000 unidades do PROD_2 no período
                SELECT
                    v2.COD_LOJA
                FROM
                    vendas v2
                WHERE
                    v2.COD_PRODUTO = 'PROD_2'
                    AND v2.DATA_VENDA BETWEEN DATA_INICIO AND DATA_FIM
                GROUP BY
                    v2.COD_LOJA
                HAVING
                    SUM(v2.QUANTIDADE) > 1000
            )
        GROUP BY
            v1.COD_LOJA
    ) mv ON v.COD_LOJA = mv.COD_LOJA
WHERE
    v.COD_PRODUTO = 'PROD_2'
    AND v.DATA_VENDA BETWEEN DATA_INICIO AND DATA_FIM
    AND v.QUANTIDADE > mv.media_vendas;

/*
### QUESTÃO 2

Esboce uma consulta SQL que retorne o código de todos os vendedores cujas vendas
do produto de código PROD_1 entre DATA_INICIO e DATA_FIM foram sempre
crescentes dia-a-dia

*/
SELECT DISTINCT
    v1.COD_VENDEDOR
FROM
    vendas v1
    JOIN vendas v2 ON v1.COD_VENDEDOR = v2.COD_VENDEDOR
    AND v1.DATA_VENDA = DATE_SUB (v2.DATA_VENDA, INTERVAL 1 DAY)
WHERE
    v1.COD_PRODUTO = 'PROD_1'
    AND v2.COD_PRODUTO = 'PROD_1'
    AND v1.DATA_VENDA BETWEEN DATA_INICIO AND DATA_FIM
    AND v2.DATA_VENDA BETWEEN DATA_INICIO AND DATA_FIM
    AND v1.QUANTIDADE < v2.QUANTIDADE
GROUP BY
    v1.COD_VENDEDOR
HAVING
    COUNT(DISTINCT v1.DATA_VENDA) = (
        SELECT
            COUNT(DISTINCT v3.DATA_VENDA)
        FROM
            vendas v3
        WHERE
            v3.COD_VENDEDOR = v1.COD_VENDEDOR
            AND v3.COD_PRODUTO = 'PROD_1'
            AND v3.DATA_VENDA BETWEEN DATA_INICIO AND DATA_FIM
    );
