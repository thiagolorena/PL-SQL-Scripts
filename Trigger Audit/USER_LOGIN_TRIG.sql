CREATE OR REPLACE TRIGGER NGIN_USER_LOGIN_TRIG

/* Nome: NGIN_USER_LOGIN_TRIG
Descricao: Trigger de auditoria para logins no BLINDADO
Funcao: A trigger coleta os dados dos usuÃ¡rios que logam nas bases de dados blindadas, guardando na tabela user_login_audit os dados dos usuarios para possivel trace.
Data: 27/07/2016
Criado por: Thiago Lorena (thiago.lorena@ericssoninovacao.com.br)
Controle de VersÃ£o:

1.0:
    Trigger utilizando os campos (username, osuser, machine, command e program da tabela v$session). Sem bugs reportados.
*/

AFTER LOGON ON <SCHEMA>.SCHEMA
DECLARE
v_username sys.v_$session.username%TYPE;
v_osuser   sys.v_$session.osuser%TYPE;
v_machine  sys.v_$session.machine%TYPE;
v_command  sys.v_$session.command%TYPE;
v_program  sys.v_$session.program%TYPE;
BEGIN
SELECT username, osuser, machine, command, program
 INTO v_username,  v_osuser, v_machine, v_command, v_program
 FROM sys.v_$session
WHERE audsid = USERENV('SESSIONID')
  AND audsid != 0  -- NÃ£o checa usuarios SYS
  AND ROWNUM = 1  -- Pega seÃ§Ãµes paralelas com o mesmo AUDSID
  AND PROGRAM not like '%oracle@%';

INSERT INTO <SCHEMA>.user_login_audit
  VALUES (SYSDATE, v_username,  v_osuser, v_machine, v_command, v_program);

END;
/
