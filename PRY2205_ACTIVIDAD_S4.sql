
-- CASO 1: LISTADO DE TRABAJADORES

SELECT
    UPPER(TRIM(t.nombre) || ' ' ||
          TRIM(t.appaterno) || ' ' ||
          TRIM(t.apmaterno)) AS "Nombre Completo Trabajador",

    TO_CHAR(t.numrut, 'FM99G999G999',
            'NLS_NUMERIC_CHARACTERS='',.''') ||
            '-' || UPPER(t.dvrut) AS "RUT Trabajador",

    UPPER(tt.desc_categoria) AS "Tipo Trabajador",

    UPPER(c.nombre_ciudad) AS "Ciudad Trabajador",

    '$' || TO_CHAR(ROUND(t.sueldo_base),
            'FM999G999G999',
            'NLS_NUMERIC_CHARACTERS='',.''') AS "Sueldo Base"

FROM trabajador t

INNER JOIN tipo_trabajador tt
    ON t.id_categoria_t = tt.id_categoria

INNER JOIN comuna_ciudad c
    ON t.id_ciudad = c.id_ciudad

WHERE t.sueldo_base BETWEEN 650000 AND 3000000

ORDER BY UPPER(c.nombre_ciudad) DESC,
         t.sueldo_base ASC;
         
         
-- CASO 2: LISTADO DE CAJEROS

SELECT
    TO_CHAR(t.numrut, 'FM99G999G999',
            'NLS_NUMERIC_CHARACTERS='',.''') ||
            '-' || UPPER(t.dvrut) AS "RUT Trabajador",

    INITCAP(TRIM(t.nombre)) || ' ' ||
    UPPER(TRIM(t.appaterno)) AS "Nombre Trabajador",

    COUNT(tc.nro_ticket) AS "Total Tickets",

    '$' || TO_CHAR(ROUND(SUM(tc.monto_ticket)),
            'FM999G999G999',
            'NLS_NUMERIC_CHARACTERS='',.''')
            AS "Total vendido",

    '$' || TO_CHAR(ROUND(SUM(NVL(ct.valor_comision, 0))),
            'FM999G999G999',
            'NLS_NUMERIC_CHARACTERS='',.''')
            AS "Comision Total",

    UPPER(tt.desc_categoria) AS "Tipo Trabajador",

    UPPER(c.nombre_ciudad) AS "Ciudad Trabajador"

FROM trabajador t

INNER JOIN tipo_trabajador tt
    ON t.id_categoria_t = tt.id_categoria

INNER JOIN comuna_ciudad c
    ON t.id_ciudad = c.id_ciudad

INNER JOIN tickets_concierto tc
    ON t.numrut = tc.numrut_t

LEFT JOIN comisiones_ticket ct
    ON tc.nro_ticket = ct.nro_ticket

WHERE UPPER(tt.desc_categoria) = 'CAJERO'

GROUP BY
    t.numrut,
    t.dvrut,
    t.nombre,
    t.appaterno,
    tt.desc_categoria,
    c.nombre_ciudad

HAVING SUM(tc.monto_ticket) > 50000

ORDER BY SUM(tc.monto_ticket) DESC;


-- CASO 3: LISTADO DE BONIFICACIONES

SELECT
    TO_CHAR(t.numrut, 'FM99G999G999',
            'NLS_NUMERIC_CHARACTERS='',.''') ||
            '-' || UPPER(t.dvrut) AS "RUT Trabajador",

    INITCAP(TRIM(t.nombre) || ' ' ||
            TRIM(t.appaterno)) AS "Trabajador Nombre",

    EXTRACT(YEAR FROM t.fecing) AS "Año Ingreso",

    TRUNC(MONTHS_BETWEEN(SYSDATE, t.fecing) / 12)
        AS "Años Antiguedad",

    NVL(cf.total_cargas, 0) AS "Num Cargas Familiares",

    INITCAP(i.nombre_isapre) AS "Nombre Isapre",

    '$' || TO_CHAR(ROUND(t.sueldo_base),
            'FM999G999G999',
            'NLS_NUMERIC_CHARACTERS='',.''')
        AS "Sueldo Base",

    '$' || TO_CHAR(
        CASE
            WHEN UPPER(i.nombre_isapre) = 'FONASA'
            THEN ROUND(t.sueldo_base * 0.01)
            ELSE 0
        END,
        'FM999G999G999',
        'NLS_NUMERIC_CHARACTERS='',.''')
        AS "Bono Fonasa",

    '$' || TO_CHAR(
        ROUND(t.sueldo_base *
            CASE
                WHEN TRUNC(
                    MONTHS_BETWEEN(SYSDATE, t.fecing) / 12
                ) <= 10 THEN 0.10
                ELSE 0.15
            END),
        'FM999G999G999',
        'NLS_NUMERIC_CHARACTERS='',.''')
        AS "Bono Antiguedad",

    INITCAP(a.nombre_afp) AS "Nombre AFP",

    UPPER(ec.desc_estcivil) AS "Estado Civil"

FROM trabajador t

INNER JOIN isapre i
    ON t.cod_isapre = i.cod_isapre

INNER JOIN afp a
    ON t.cod_afp = a.cod_afp

INNER JOIN est_civil e
    ON t.numrut = e.numrut_t

INNER JOIN estado_civil ec
    ON e.id_estcivil_est = ec.id_estcivil

LEFT JOIN (
    SELECT numrut_t, COUNT(*) AS total_cargas
    FROM asignacion_familiar
    GROUP BY numrut_t
) cf
    ON t.numrut = cf.numrut_t

WHERE e.fecter_estcivil IS NULL
   OR e.fecter_estcivil > SYSDATE

ORDER BY t.numrut ASC;


