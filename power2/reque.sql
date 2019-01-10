set NewPage none
set heading off
select *  from dba_profiles where profile = (select profile from DBA_USERS where username = 'SYSTEM');
exit
