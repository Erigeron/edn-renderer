import assert from 'node:assert/strict';
import {execFileSync} from 'node:child_process';
import {mkdirSync,readFileSync,writeFileSync} from 'node:fs';
const run=(...a)=>execFileSync('calcit',a,{encoding:'utf8',maxBuffer:32e6,stdio:['ignore','pipe','pipe']});
const norm=v=>Array.isArray(v)?v.map(norm):v&&typeof v==='object'?Object.fromEntries(Object.entries(v).map(([k,x])=>[k,k==='__edn_set'?x.map(norm).sort((a,b)=>JSON.stringify(a).localeCompare(JSON.stringify(b))):norm(x)])):v;
const q=(...a)=>norm(JSON.parse(run('query',...a,'--format','json')).data);
const blob=()=>execFileSync('git',['hash-object','calcit.cirru'],{encoding:'utf8'}).trim();
assert.equal(run('-v').trim(),'0.30.1');assert.equal(blob(),'d9be15fe7b1f4a7b8d738d66510a64bc37358468');
mkdirSync('acceptance',{recursive:true});writeFileSync('acceptance/agent-contract.txt',run('docs','agents','--contract'));
const before=norm(JSON.parse(readFileSync('reviewed.json','utf8'))),expected=structuredClone(before),ops=[],counts={};
assert.equal(before.length,110);
const config=q('config'),namespaces=q('ns').namespaces.map(n=>q('ns',n));
function replace(id,path,old,value){assert.deepEqual(JSON.parse(run('tree','show',id,'--path','@'+path.join('.'),'--format','json')).tree,old);ops.push(['tree','replace',id,'--path','@'+path.join('.'),'--input-format','json-ast','--code',JSON.stringify(value),...(typeof old==='string'?['--expect','quote '+old]:[])]);}
function walk(x,path,id){
  if(!Array.isArray(x)||['quote','quasiquote',';','comment','defmacro'].includes(x[0]))return x;
  if(['app.comp.container/dispose-echarts-on!','app.comp.container/render-echarts-on!'].includes(id)&&x[0]==='js-present?'&&x[1]==='existing'){
    const value=['not',['js-nullish?','existing']];replace(id,path,x,value);counts.nullish=(counts.nullish||0)+1;return value;
  }
  const head=x[0],alias={count:'.len',foldl:'.foldl',merge:'.merge'}[head];
  if(alias){counts[head]=(counts[head]||0)+1;replace(id,[...path,0],head,alias);x[0]=alias;}
  if(head==='unsafe-coerce'){
    let replacement;
    if(id.endsWith('/render-mermaid-on')&&x[2]==='MermaidResultHost')return x;
    if(x[2]==='JsObject')replacement=['contract/expect-object','|'+id.split('/')[1],structuredClone(x[1])];
    else if(Array.isArray(x[2])&&x[2][0]==='::'&&x[2][1]==="'JsNullish")replacement=structuredClone(x[1]);
    else{assert.ok(['MathElementHost','EChartHost','MermaidHost'].includes(x[2]));replacement=['js-cast',structuredClone(x[1]),"'"+x[2]];}
    replace(id,path,x,replacement);counts.host=(counts.host||0)+1;return replacement;
  }
  return x.map((v,i)=>walk(v,[...path,i],id));
}
for(const d of expected){assert.deepEqual(q('def',d.id),before.find(x=>x.id===d.id));d.code=walk(d.code,[],d.id);}
assert.deepEqual(counts,{host:15,merge:9,foldl:6,count:20,nullish:2});assert.equal(ops.length,52);
ops.push(['edit','add-import','app.comp.container','--input-format','json-ast','--code',JSON.stringify(['js-ffi.contract',':as','contract'])]);
writeFileSync('acceptance/operations.json',JSON.stringify(ops,null,2));
const args=['edit','transaction','--file','acceptance/operations.json','--format','json'];
const preview=JSON.parse(run(...args,'--dry-run'));assert.ok(preview.scoped_revision);writeFileSync('acceptance/transaction-preview.json',JSON.stringify(preview,null,2));
writeFileSync('acceptance/transaction-applied.json',run(...args,'--expect-revision',preview.scoped_revision));
const actual=[];for(const ns of namespaces){const names=run('query','defs',ns.namespace).split('\n').filter(x=>/^  \S/.test(x)).map(x=>x.trim().split(' ')[0]);assert.equal(names.length,ns.definition_count);for(const n of names)actual.push(q('def',`${ns.namespace}/${n}`));}
assert.deepEqual(actual,expected);assert.deepEqual(q('config'),config);
const expectedNs=structuredClone(namespaces);expectedNs.find(n=>n.namespace==='app.comp.container').ns_code[2].push(['js-ffi.contract',':as','contract']);
assert.deepEqual(q('ns').namespaces.map(n=>q('ns',n)),expectedNs);
writeFileSync('acceptance/after.json',JSON.stringify(actual,null,2));writeFileSync('acceptance/config.json',JSON.stringify(config,null,2));writeFileSync('acceptance/namespaces.json',JSON.stringify(expectedNs,null,2));
writeFileSync('acceptance/summary.json',JSON.stringify({definitions:110,operations:ops.length,counts,remainingUnsafe:1,preserved:'all other code,metadata,schemas,tests,FFI,entries,storage,HUD,Mermaid lock/order/optional callback and existing workflows;shape checks do not prove payloads'},null,2));
writeFileSync('acceptance/snapshot-after-blob.txt',blob());
