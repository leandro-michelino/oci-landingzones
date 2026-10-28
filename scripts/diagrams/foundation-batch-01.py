#!/usr/bin/env python3
"""Core, CIS and Identity catalog entries 1-5 using the OCI diagram skill.

Requires the installed oci-architecture-diagrams skill and official v24.2 toolkit.
Run with --render for draw.io PNG export. Documentation only; no cloud calls.
"""
import argparse
import os
from pathlib import Path
import sys

ROOT=Path(__file__).resolve().parents[2]
SKILL=Path(os.environ.get('OCI_DIAGRAM_SKILL',Path.home()/'.codex/skills/oci-architecture-diagrams'))
sys.path.insert(0,str(SKILL/'scripts'))
from ocidraw import Diagram
TOOLKIT=os.environ.get('OCI_TOOLKIT',str(SKILL/'toolkit'))
ITEMS=[
    ('core','Core landing zone | Default foundation','core'),
    ('cis/level1','CIS Level 1 | Source-defined foundation','level1'),
    ('cis/level2','CIS Level 2 | Source-defined foundation','level2'),
    ('identity/cis-basic','CIS basic identity | Opt-in IAM baseline','identity'),
    ('identity/new-identity-domain','New identity domain | Conditional creation','domain'),
]


def header(title,index):
    d=Diagram(toolkit=TOOLKIT,title=title)
    d.text(title,20,10,2360,45,size=25,bold=True)
    d.text(f'FOUNDATION / IDENTITY {index:02} / Official OCI Toolkit v24.2 / Defaults and optional scope / Documentation view',20,65,2360,30,size=13)
    return d


def footer(d,text,y=1190):
    d.box(text,20,y,2360,130,kind='note')


def foundation(title,index,kind):
    cis=kind!='core'
    d=header(title,index)
    home=d.group('other','IAM / home-region provider: coalesce(home_region, region)',20,160,2360,260)
    d.icon('User Group',250,110,parent=home,size=52,label='Groups / 6 default roles',label_pos='top')
    dyn=d.box('Dynamic groups / 2 defaults\nPlatform automation + workload instances\nMatching rules reference governance/workloads compartments',600,65,630,140,parent=home)
    policies=d.icon('Policies',1600,110,parent=home,size=52,label='Default IAM policies\nHome-region provider; parent compartment placement',label_pos='top')
    d.connect(dyn,policies,kind='dashed',straight=True)
    d.text('Groups and dynamic groups are tenancy resources. Policy grants target the landing-zone compartment tree; review the actual statements.',30,215,2300,30,parent=home,size=12)
    region=d.group('region','Regional services + compartment hierarchy / selected region',20,470,2360,650)
    root=d.group('compartment','Landing-zone root / created under parent_compartment_ocid (tenancy fallback)',20,50,2320,580,parent=region)
    gov=d.group('compartment','governance / default child compartment',30,60,1100,350,parent=root)
    sec=d.group('compartment','security / default child compartment',1190,60,1100,350,parent=root)
    d.icon('Tagging',150,95,parent=gov,size=48,label='Tags + defaults\nHome-region provider',label_pos='top')
    d.icon('Logging',425,95,parent=gov,size=48,label='4 default log groups',label_pos='top')
    if cis:
        ev=d.icon('Events',700,95,parent=gov,size=48,label='3 default IAM event rules\nRules target tenancy root',label_pos='top')
        topic=d.icon('Notifications',970,95,parent=gov,size=48,label='Events topic',label_pos='top')
        d.connect(ev,topic,straight=True)
    else:
        d.box('Events + Notifications\nDisabled by default',630,65,430,95,parent=gov,kind='optional')
    d.text('Logging: audit / network / service / security groups. Service/flow-log and saved-search maps are empty.\nTags apply defaults to created compartments; this does not create workload data.\n'+('Audit retention requested: 365 days, tenancy-wide. Events have no subscriptions by default.' if cis else 'Audit-retention changes are disabled by default. Events, monitoring and budgets are disabled.'),20,195,1060,115,parent=gov,size=12)
    cg=d.group('other' if cis else 'optional','Cloud Guard / enabled by default' if cis else 'Cloud Guard / disabled by default',20,60,500,245,parent=sec,style_extra='verticalAlign=top;spacingTop=12;')
    d.icon('Cloud Guard',75,100,parent=cg,size=52,label='',label_pos='bottom')
    d.text('Tenancy-wide configuration.\nTarget created in security compartment,\ncovering landing-zone root.\nRecipe ID lists default empty.' if cis else 'No configuration or target is created\nunder the default Core inputs.\nEnablement would include tenancy-wide\nconfiguration + root-compartment target.',160,60,310,150,parent=cg,size=12)
    opt=d.group('optional','Optional security services / all disabled by default',560,60,520,245,parent=sec,style_extra='verticalAlign=top;spacingTop=12;')
    d.icon('Vault',90,100,parent=opt,size=44,label='Vault / KMS',label_pos='bottom')
    d.icon('Vulnerability Scanning',260,100,parent=opt,size=44,label='VSS',label_pos='bottom')
    d.icon('Maximum Security Zone',430,100,parent=opt,size=44,label='Security Zones',label_pos='bottom')
    d.text('Enablement and customer inputs required.\nSecurity Zones depend on Cloud Guard and a recipe.',20,180,480,45,parent=opt,size=12)
    d.box('network / default child compartment\nNo VCN, DRG or subnet created by this foundation.',30,455,1100,90,parent=root)
    d.box('workloads / default child compartment\nNo workload instances, databases or application ingress.',1190,455,1100,90,parent=root)
    text=('CORE DEFAULTS: Compartments, tags, log groups, default IAM groups, dynamic groups and policies are enabled.\nCloud Guard, Vault, Security Zones, VSS, Events, Monitoring and Budgets are opt-in. Default parent = tenancy; review IAM/global scope before apply.\nThe log groups do not imply Audit-event ingestion or VCN flow-log collection.' if not cis else f'CIS {kind.upper()}: Uses pinned Core with cis_level={kind} and a compliance tag.\nAudit retention, Cloud Guard and Events are enabled; Vault, Security Zones, VSS and Monitoring are disabled. Budget creation needs amount/map inputs.\nLevel 1 and Level 2 wrappers currently have the same service-enable defaults; the label alone is not CIS certification or full control coverage.')
    footer(d,text)
    return d


def identity(title,index):
    d=header(title,index)
    scope=d.group('other','OCI IAM / tenancy home region (home_region fallback: region)',20,160,2360,770)
    d.text('Default target_compartment_ocid = tenancy_ocid unless explicitly supplied.\nGroup/dynamic-group operations and policy scope must be reviewed against the referenced modules and actual policy statements.',30,60,2300,65,parent=scope,size=14)
    modules=[]
    for i,(name,icon,text) in enumerate([
        ('module.groups','User Group','enable_default_groups=false\ngroups={}\nNo users or memberships are created.'),
        ('module.dynamic_groups','IAM','dynamic_groups={}\nMatching rules supplied per entry.\nNo default dynamic groups in this wrapper.'),
        ('module.policies','Policies','enable_default_policies=false\npolicies={}\nLocal CIS policy maps are gated by opt-in.')]):
        panel=d.group('optional',name+' / no resources under defaults',30+i*780,190,740,420,parent=scope,style_extra='verticalAlign=top;spacingTop=12;')
        node=d.icon(icon,370,130,parent=panel,size=60,label=name.split('.')[-1],label_pos='top')
        d.text(text,30,215,680,125,parent=panel,size=15)
        modules.append(panel)
    d.connect(modules[0],modules[2],kind='dashed',exit=(.5,1),entry=(.5,1),waypoints=[(420,840),(1980,840)],label='Configured group names feed local CIS policy statements')
    footer(d,'DEFAULT RESULT: No IAM writes. Custom maps can create resources even when default-resource flags remain false.\nOpt-in CIS policies reference created auditors, security-admins and governance-admins groups. Empty statement lists are filtered by the policy module.\nNo identity domain, federation, MFA configuration, users or security certification is created here.',1000)
    return d


def domain(title,index):
    d=header(title,index)
    home=d.group('region','IAM home region / coalesce(home_region, region)',20,160,1400,750)
    comp=d.group('compartment','Target compartment / explicit input or tenancy fallback',20,60,1360,660,parent=home)
    opt=d.group('optional','Create gate / enable_identity_domain=false',30,70,1300,500,parent=comp,style_extra='verticalAlign=top;spacingTop=12;')
    d.icon('IAM',160,160,parent=opt,size=70,label='OCI Identity Domain',label_pos='top')
    resource=d.box('oci_identity_domain.this\nDomain display name: input or generated prefix\nlicense_type=free by default; admin fields=null\nPrimary email required=true\nHidden on login=false; notification bypass=false',340,105,900,240,parent=opt)
    d.text('The diagram shows the conditional resource shape.\nNo new domain is created with the default flag.',30,400,1240,60,parent=opt,size=14)
    replica=d.group('optional','Additional regions / explicitly selected only',1530,160,850,750,style_extra='verticalAlign=top;spacingTop=12;')
    repl=d.box('oci_identity_domain_replication_to_region.replicas\nreplica_regions=[] by default\nOne resource per selected region, only if domain creation is enabled.\nReplica locations TBC; no region is assumed.',30,190,790,220,parent=replica)
    d.connect(resource,repl,kind='dashed',exit=(1,.5),entry=(0,.5),waypoints=[(1470,545),(1470,620)],label='Conditional replication configuration')
    footer(d,'DEFAULT RESULT: No identity domain or replicas. Supply approved admin, license, home-region and compartment inputs before enabling creation.\nNo users, groups, apps, federation, login policy or workload access is configured by these two resources.\nThe license value shown is an input default, not a cost or licensing assessment. Replication arrows are configuration dependencies, not tested availability.',1000)
    return d


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--render',action='store_true')
    args=parser.parse_args()
    for index,(slug,title,kind) in enumerate(ITEMS,1):
        d=foundation(title,index,kind) if kind in ('core','level1','level2') else identity(title,index) if kind=='identity' else domain(title,index)
        warnings=d.check()
        print(slug,warnings,flush=True)
        if warnings:
            raise RuntimeError('Fix all layout warnings before export')
        out=ROOT/'blueprints'/slug/'architecture/architecture.drawio'
        d.save(str(out))
        if args.render and not d.render(str(out.with_suffix('.png')),scale=1.5):
            raise RuntimeError('draw.io export failed')
        with out.open('a') as stream:
            stream.write('\n')


if __name__=='__main__':
    main()
