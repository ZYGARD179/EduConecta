CREATE OR REPLACE TYPE BODY TIPO_DIRECCION AS

    CONSTRUCTOR FUNCTION TIPO_DIRECCION(
        p_calle VARCHAR2,
        p_ciudad VARCHAR2,
        p_lat NUMBER,
        p_lon NUMBER
    ) RETURN SELF AS RESULT IS
    BEGIN

        -- Validación de negocio
        IF p_lat IS NULL OR p_lon IS NULL THEN
            RAISE_APPLICATION_ERROR(
                -20001,
                'Latitud y longitud son obligatorias'
            );
        END IF;

        -- Asignación de valores
        SELF.calle      := p_calle;
        SELF.ciudad     := p_ciudad;
        SELF.referencia := NULL;
        SELF.latitud    := p_lat;
        SELF.longitud   := p_lon;

        RETURN;
    END;

    MEMBER FUNCTION distancia_a(
        otra TIPO_DIRECCION
    ) RETURN NUMBER IS
        v_radio CONSTANT NUMBER := 6371;
        v_dlat NUMBER;
        v_dlon NUMBER;
        v_a    NUMBER;
        v_c    NUMBER;
    BEGIN

        IF otra IS NULL THEN
            RETURN NULL;
        END IF;

        v_dlat := (otra.latitud - SELF.latitud) * ACOS(-1) / 180;
        v_dlon := (otra.longitud - SELF.longitud) * ACOS(-1) / 180;

        v_a :=
            SIN(v_dlat / 2) * SIN(v_dlat / 2)
            + COS(SELF.latitud * ACOS(-1) / 180)
            * COS(otra.latitud * ACOS(-1) / 180)
            * SIN(v_dlon / 2) * SIN(v_dlon / 2);

        v_c := 2 * ATAN2(SQRT(v_a), SQRT(1 - v_a));

        RETURN v_radio * v_c;
    END;

END;
/