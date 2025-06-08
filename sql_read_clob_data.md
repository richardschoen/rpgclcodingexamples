# RPG SQL Sample to read Clob Data. 
You can also read clob_file which writes file contents ot the IFS

```
**FREE
//
Ctl-Opt DftActGrp(*No) Option(*Srcstmt : *NodebugIO) main(qOllama);

dcl-s MyAnswer SQLTYPE(clob:16000000);
dcl-s DspStr varchar(52);

dcl-proc qOllama;

  exec sql call dbsdk_v1.ollama_setmodelforme(model => 'granite-code:8b');
  exec sql select dbsdk_v1.ollama_generate(prompt => '{ "role": "user", "content": "why do dogs bark?"}') into :MyAnswer from SYSIBM.SYSDUMMY1;
  DspStr = MyAnswer_DATA;
  dsply DspStr;

  *inlr=*on;
end-Proc;
```

## Links

Reading a file in the IFS with SQL   
https://www.rpgpgm.com/2020/11/reading-file-in-ifs-with-sql.html

Copying any data to and from a file in the IFS   
https://www.rpgpgm.com/2018/08/copying-any-data-to-and-from-file-in-ifs.html

Read an IFS file using RPG   
https://www.rpgpgm.com/2016/01/read-ifs-file-using-rpg.html   





