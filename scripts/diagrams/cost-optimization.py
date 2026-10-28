#!/usr/bin/env python3
"""Source-bounded final original catalog entry: FinOps tags, budgets and optional alerts."""
import argparse,importlib.util
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2];SLUG='operations/cost-optimization'
def load(name):
 s=importlib.util.spec_from_file_location(name,Path(__file__).with_name(name+'.py'));m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
base=load('extensions-batch-03')
def build():
 d,r=base.frame('Cost Optimization | Tag attribution, soft budgets and optional notification paths',56,True)
 tags=d.icon('Tagging',500,180,parent=r,size=65,label='Home provider: tagging enabled by default\nNamespace + six tag definitions / CostCenter tracks cost\nTag defaults disabled / explicit compartment map',label_pos='top')
 targets=d.box('Existing approved target compartments\nTag-default values are metadata, not resource creation\nWorkload compartment falls back to tenancy if not supplied',1100,110,820,140,parent=r,kind='optional')
 d.connect(tags,targets,kind='plain',label='Optional tag defaults / definition IDs and compartment map',straight=True)
 budget=d.box('Optional native Budgets / enable_budgets=false\nHome provider / budget owner: tenancy root\nSpending targets: compartment or tag / default budget flag=true\nSoft limit; no spending stop or automatic remediation',100,455,800,155,parent=r)
 alert=d.box('Native budget alert rules\nACTUAL / PERCENTAGE / threshold 80 by default\nRecipients supplied directly; no ONS dependency',1100,455,820,155,parent=r)
 mail=d.box('Supplied budget email recipient strings\nNo email account or subscription created\nNo budget-to-ONS connection is declared',2100,455,760,155,parent=r,kind='optional')
 d.connect(alert,budget,kind='plain',label='budget_id / per-budget alert definitions',straight=True)
 d.connect(alert,mail,label='Native budget alert delivery intent / configured recipients',straight=True)
 topic=d.icon('Notifications',2500,820,parent=r,size=65,label='Optional FinOps topic / enable_notifications=false\nOptional subscriptions + Events rules from maps\nSubscription protocol, endpoint and action targets supplied',label_pos='top')
 alarm=d.icon('Alarms',1500,820,parent=r,size=65,label='Optional MQL alarm / enable_budget_alarm=false\nQuery must be supplied and destinations nonempty\nCustom monitoring_alarms are independent input entries',label_pos='top')
 d.connect(alarm,topic,label='Default alarm destinations include created FinOps topic if enabled',straight=True)
 supplied=d.box('Additional existing alarm destination IDs\nPer-alarm explicit destinations / no target resources created\nEvents can also select external Function / stream / topic IDs',100,750,800,145,parent=r,kind='optional')
 d.connect(alarm,supplied,kind='plain',label='Explicit destination IDs / optional overrides',straight=True)
 d.text('Optional Optimizer enrollment: supplied enrollment_status_id + enable flag; status defaults ENABLED.\nProfiles: enable_optimizer_profiles=false; scoped target compartments/tags + optional recommendation-level settings.\nOptional IAM policy / supplied statements / home provider / policy compartment defaults to tenancy.\nOptimizer configuration is not a resize, shutdown, recommendation acceptance or guaranteed saving.',100,990,2770,110,parent=r,size=17)
 return base.finish(d,'DEFAULT RESULT: Seven OCI resource instances from tagging: one namespace + six definitions. No budgets, ONS, alarms, Optimizer or IAM by default.\nFour pinned modules plus three root resource declarations; companion pages include all conditional/transitive declarations and existing-reference inputs.\nBudgets and tagging use the home provider; tenancy-root ownership is distinct from spending target compartments.',True)
def main():
 p=argparse.ArgumentParser();p.add_argument('--render',action='store_true');a=p.parse_args();d=build();w=d.check()+d._crossings([n for n in d.nodes if n.kind=='text']);print(SLUG,w,flush=True);assert not w
 path=ROOT/'blueprints'/SLUG/'architecture/architecture.drawio';d.save(str(path))
 if a.render:assert d.render(str(path.with_suffix('.png')),scale=1.5)
 with path.open('a') as f:f.write('\n')
if __name__=='__main__':main()
