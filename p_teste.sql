CREATE TABLE obj AS SELECT * FROM dba_objects;
CREATE TABLE obj2 AS SELECT * FROM dba_objects;
ALTER TABLE obj2 ADD CONSTRAINT ob2_pk PRIMARY KEY (object_id);
CREATE TABLE ctl_teste (cod NUMBER, valor number, CONSTRAINT ct_pk PRIMARY KEY (cod));

CREATE OR REPLACE PACKAGE p_teste IS
  PROCEDURE p_log_time_init;
  PROCEDURE p_log_time_end;
  PROCEDURE p_start_batch(p_commit BOOLEAN DEFAULT FALSE);
  PROCEDURE p_stop_batch;
  PROCEDURE p_start_online;
  PROCEDURE p_stop_online;
  PROCEDURE p_start_online_hrd_parse;
  PROCEDURE p_stop_online_hrd_parse;
END p_teste;
/
CREATE OR REPLACE PACKAGE BODY p_teste IS

  SUBTYPE ts IS TIMESTAMP(9) WITH TIME ZONE;

  BATCH CONSTANT ctl_teste.cod%TYPE := 1;
  ONLIN CONSTANT ctl_teste.cod%TYPE := 2;
  HRDPS CONSTANT ctl_teste.cod%TYPE := 3;
  PLAY  CONSTANT ctl_teste.valor%TYPE := 1;
  STOP  CONSTANT ctl_teste.valor%TYPE := 0;

  g_get_time  NUMBER;
  g_timestamp ts;

  FUNCTION f_delta(p_interval INTERVAL DAY TO SECOND) RETURN NUMBER IS
  
  BEGIN
    RETURN EXTRACT(DAY FROM p_interval) * 60 * 60 * 24 + EXTRACT(HOUR FROM
                                                                 p_interval) * 60 * 60 + EXTRACT(MINUTE FROM
                                                                                                 p_interval) * 60 + EXTRACT(SECOND FROM
                                                                                                                            p_interval);
  END f_delta;

  PROCEDURE p_log_time_init IS
  BEGIN
    g_timestamp := systimestamp;
  END;

  PROCEDURE p_log_time_end IS
    v_timestamp ts := systimestamp;
  BEGIN
    dbms_application_info.set_client_info(NVL(TO_CHAR(1 / NULLIF(f_delta(v_timestamp -
                                                                         g_timestamp),
                                                                 0),
                                                      'fm999999999999999900.00'),
                                              'NULL') || ' TPS');
  END;

  FUNCTION f_cod_val(p_cod ctl_teste.cod%TYPE) RETURN ctl_teste.valor%TYPE IS
    v_val_ret ctl_teste.valor%TYPE;
  BEGIN
    SELECT valor
    INTO   v_val_ret
    FROM   ctl_teste
    WHERE  cod = p_cod;
  
    RETURN v_val_ret;
  END;

  FUNCTION f_continue(p_cod ctl_teste.cod%TYPE) RETURN BOOLEAN IS
  
  BEGIN
    RETURN NVL(f_cod_val(p_cod), STOP) = PLAY;
  END;

  PROCEDURE p_upd(p_cod   ctl_teste.cod%TYPE
                 ,p_valor ctl_teste.valor%TYPE) IS
  
  BEGIN
    UPDATE ctl_teste
    SET    valor = p_valor
    WHERE  cod = p_cod;
    IF SQL%ROWCOUNT = 0 THEN
      INSERT INTO ctl_teste
        (cod
        ,valor)
      VALUES
        (p_cod
        ,p_valor);
    END IF;
    COMMIT;
  END p_upd;

  PROCEDURE p_start_batch(p_commit BOOLEAN DEFAULT FALSE) IS
  BEGIN
    dbms_application_info.set_module(module_name => 'TST-BATCH',
                                     action_name => 'INICIO');
    p_upd(BATCH, PLAY);
  
    WHILE f_continue(BATCH)
    LOOP
      p_log_time_init;
      UPDATE OBJ
      SET    owner = TO_CHAR(SYSDATE, 'rrrr/mm/dd hh24:mi:ss');
      p_log_time_end;
      IF p_commit THEN
        COMMIT;
      END IF;
    END LOOP;
    COMMIT;
  END p_start_batch;

  PROCEDURE p_stop_batch IS
  BEGIN
    p_upd(BATCH, STOP);
    COMMIT;
  END p_stop_batch;

  PROCEDURE p_start_online IS
    CURSOR c_obj IS
      SELECT ROWID
      FROM   obj2
      ORDER  BY dbms_random.value;
    rids dbms_sql.urowid_table;
  BEGIN
    dbms_application_info.set_module(module_name => 'TST-ONLINE',
                                     action_name => 'INICIO');
    p_upd(ONLIN, PLAY);
  
    <<fora>>
    LOOP
      OPEN c_obj;
      FETCH c_obj BULK COLLECT
        INTO rids;
      CLOSE c_obj;
    
      FOR i IN 1 .. rids.count
      LOOP
        p_log_time_init;
        UPDATE OBJ2
        SET    owner = TO_CHAR(SYSDATE, 'rrrr/mm/dd hh24:mi:ss')
        WHERE  ROWID = rids(i);
        p_log_time_end;
        COMMIT;
        EXIT fora WHEN NOT f_continue(ONLIN);
      END LOOP;
    END LOOP;
    COMMIT;
  
  END p_start_online;

  PROCEDURE p_stop_online IS
  
  BEGIN
    p_upd(ONLIN, STOP);
    COMMIT;
  END p_stop_online;

  PROCEDURE p_start_online_hrd_parse IS
    CURSOR c_obj IS
      SELECT ROWID
      FROM   obj2
      ORDER  BY dbms_random.value;
    rids dbms_sql.urowid_table;
  BEGIN
    dbms_application_info.set_module(module_name => 'TST-ONL-HARD_PARSE',
                                     action_name => 'INICIO');
    p_upd(HRDPS, PLAY);
  
    <<fora>>
    LOOP
      OPEN c_obj;
      FETCH c_obj BULK COLLECT
        INTO rids;
      CLOSE c_obj;
    
      FOR i IN 1 .. rids.count
      LOOP
        p_log_time_init;
        EXECUTE IMMEDIATE 'update obj2 set owner=''' ||
                          TO_CHAR(SYSDATE, 'rrrr/mm/dd hh24:mi:ss') ||
                          ''' where rowid=''' || rids(i) || '''';
        p_log_time_end;
        COMMIT;
        EXIT fora WHEN NOT f_continue(HRDPS);
      END LOOP;
    END LOOP;
    COMMIT;
  
  END p_start_online_hrd_parse;

  PROCEDURE p_stop_online_hrd_parse IS
  
  BEGIN
    p_upd(HRDPS, STOP);
    COMMIT;
  END p_stop_online_hrd_parse;

END p_teste;
/
