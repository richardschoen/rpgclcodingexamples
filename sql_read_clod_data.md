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
