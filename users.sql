SELECT * FROM v$instance;
SELECT * FROM v$session;

ALTER SYSTEM FLUSH SHARED_POOL;

CREATE ROLE LMEET_HANDS_ON NOT IDENTIFIED;

GRANT CREATE SESSION TO lmeet_hands_on;
GRANT CREATE TABLE TO lmeet_hands_on;

CREATE USER elio IDENTIFIED BY showpeta DEFAULT tablespace users TEMPORARY TABLESPACE temp quota unlimited ON users;
GRANT lmeet_hands_on TO elio;

CREATE USER victor IDENTIFIED BY mymaster DEFAULT tablespace users TEMPORARY TABLESPACE temp quota unlimited ON users;
GRANT lmeet_hands_on TO victor;

CREATE USER guri IDENTIFIED BY oooopa DEFAULT tablespace users TEMPORARY TABLESPACE temp quota unlimited ON users;
GRANT lmeet_hands_on TO guri;
CREATE USER massuda IDENTIFIED BY massudo DEFAULT tablespace users TEMPORARY TABLESPACE temp quota unlimited ON users;
GRANT lmeet_hands_on TO massuda;


CREATE USER user1 IDENTIFIED BY user1 DEFAULT tablespace users TEMPORARY TABLESPACE temp quota unlimited ON users;
GRANT lmeet_hands_on TO user1;
CREATE USER user2 IDENTIFIED BY user2 DEFAULT tablespace users TEMPORARY TABLESPACE temp quota unlimited ON users;
GRANT lmeet_hands_on TO user2;
CREATE USER user3 IDENTIFIED BY user3 DEFAULT tablespace users TEMPORARY TABLESPACE temp quota unlimited ON users;
GRANT lmeet_hands_on TO user3;
CREATE USER user4 IDENTIFIED BY user4 DEFAULT tablespace users TEMPORARY TABLESPACE temp quota unlimited ON users;
GRANT lmeet_hands_on TO user4;
CREATE USER user5 IDENTIFIED BY user5 DEFAULT tablespace users TEMPORARY TABLESPACE temp quota unlimited ON users;
GRANT lmeet_hands_on TO user5;

GRANT EXECUTE ON SAZIBA.P_TESTE TO lmeet_hands_on;

GRANT select any dictionary TO lmeet_hands_on;





@(DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=lmeetings.cw8jnk7hzrpa.us-east-1.rds.amazonaws.com)(PORT=1521))(connect_data = (sid = ORCL)))

SELECT * FROM dba_objects;
SELECT * FROM v$session_event e WHERE e.sid = 1;

CREATE TABLE obj AS SELECT * FROM dba_objects;
CREATE TABLE obj2 AS SELECT * FROM dba_objects;
ALTER TABLE obj2 ADD CONSTRAINT ob2_pk PRIMARY KEY (object_id);

DROP TABLE obj;


CREATE TABLE ctl_teste (cod NUMBER, valor number, CONSTRAINT ct_pk PRIMARY KEY (cod));
INSERT INTO ctl_teste values(1, 1);
INSERT INTO ctl_teste values(2, 1);

DROP TABLE ctl_teste;

SELECT *
  from v$parameter;
  
  
SELECT x1.*
FROM   XMLTABLE(XMLNAMESPACES('http://schemas.xmlsoap.org/soap/envelope/' AS "banana"
                             ,'stub.ws.tananan.com.br' AS "ns2"),
                '/banana:Envelope/banana:Body/ns2:getEanResponse/ns2:eanArtigoDTO' PASSING
                Xmltype('<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/">
   <SOAP-ENV:Header/>
   <SOAP-ENV:Body>
      <ns2:getEanResponse xmlns:ns2="stub.ws.tananan.com.br">
         <ns2:eanArtigoDTO>
            <ns2:codigoartigo>300</ns2:codigoartigo>
            <ns2:codigoean>500</ns2:codigoean>
            <ns2:descricaoartigo>Iphone 7</ns2:descricaoartigo>
            <ns2:descricaocolaborador>José da Silva</ns2:descricaocolaborador>
            <ns2:estabelecimentoatual>Loja da Rua X</ns2:estabelecimentoatual>
            <ns2:imeis>
               <ns2:numero>300</ns2:numero>
               <ns2:tipoentrada>1</ns2:tipoentrada>
            </ns2:imeis>
            <ns2:notafiscal>?</ns2:notafiscal>
            <ns2:situacao>DI</ns2:situacao>
         </ns2:eanArtigoDTO>
      </ns2:getEanResponse>
   </SOAP-ENV:Body>
</SOAP-ENV:Envelope>')
COLUMNS codigoartigo VARCHAR2(4000)  PATH 'ns2:codigoartigo'
       ,codigoean VARCHAR2(4000)  PATH 'ns2:codigoean'
       ,descricaoartigo VARCHAR2(4000)  PATH 'ns2:descricaoartigo'
       ,descricaocolaborador VARCHAR2(4000)  PATH 'ns2:descricaocolaborador'
       ,estabelecimentoatual VARCHAR2(4000)  PATH 'ns2:estabelecimentoatual'
       ,numero VARCHAR2(4000)  PATH 'ns2:imeis/ns2:numero'
       ,tipoentrada VARCHAR2(4000)  PATH 'ns2:imeis/ns2:tipoentrada'
       ,notafiscal VARCHAR2(4000)  PATH 'ns2:notafiscal'
       ,situacao VARCHAR2(4000)  PATH 'ns2:situacao') x1
