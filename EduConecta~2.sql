CREATE OR REPLACE TYPE TIPO_ESTUDIANTE AS OBJECT 
(
    id_estudiante NUMBER, 
    nombre        VARCHAR2(100), 
    email         VARCHAR2(100), 
    direccion     TIPO_DIRECCION, 

    MAP MEMBER FUNCTION obtener_id RETURN NUMBER 
); 
/