#!/usr/bin/env python3
"""Custom Identity, Operating Entity and SCCA catalog diagrams.

Requires the installed OCI diagram skill and Oracle v24.2 toolkit.
Run with --render to export PNGs through draw.io. No cloud operations.
"""
import argparse
import importlib.util
from pathlib import Path

ROOT=Path(__file__).resolve().parents[2]
spec=importlib.util.spec_from_file_location('networking_batch_02',Path(__file__).with_name('networking-batch-02.py'))
base=importlib.util.module_from_spec(spec)
spec.loader.exec_module(base)
ITEMS=[
    ('identity/custom-identity-domain','Custom identity domains | Map-driven creation','domain'),
    ('operating-entity','Single operating entity | Compartment and IAM package','single'),
    ('operating-entity/multi-operating-entities','Multiple operating entities | Per-entity delegation','multi'),
    ('operating-entity/workload-vending','Workload vending | Compartment and IAM package','workload'),
    ('compliance/scca-cloud-native','SCCA cloud-native | Source-defined security foundation','scca'),
]


def header(title,index):
    d=base.Diagram(toolkit=base.TOOLKIT,title=title)
    d.text(title,20,10,2360,45,size=25,bold=True)
    d.text(f'FOUNDATION / IDENTITY {index:02} / Official OCI Toolkit v24.2 / Defaults and scope / Documentation view',20,65,2360,30,size=13)
    return d


def footer(d,text,y=1170):
    d.box(text,20,y,2360,130,kind='note')
    d.text('Arrows show configuration dependencies / IAM bindings, not application traffic or proven isolation.\nSource review: 2026-10-28. No cloud provisioning, provider revalidation, login/permission test or compliance certification.\nRegions, parent compartments and names are supplied or derived from inputs. Historical validation metadata is unchanged.',20,y+165,2360,80,size=12)


def domains(title,index):
    d=header(title,index)
    provider=d.group('other','OCI IAM home-region provider / coalesce(home_region, region)',20,160,2360,760)
    inputs=d.box('identity_domains input map\nDefault: {} (empty)\nNo separate create-enable flag\nStable key per requested domain',30,110,600,180,parent=provider)
    resource=d.group('optional','One domain per supplied map entry / none under defaults',740,70,1580,580,parent=provider,style_extra='verticalAlign=top;spacingTop=12;')
    d.icon('IAM',160,150,parent=resource,size=64,label='OCI Identity Domain',label_pos='top')
    domain=d.box('oci_identity_domain.this[key]\nCompartment: per-entry override or wrapper target (tenancy fallback)\nDomain home region: per-entry override → home_region → region\nLicense defaults free; admin fields null; primary email required=true',370,95,1160,220,parent=resource)
    replicas=d.box('oci_identity_domain_replication_to_region.replicas\nFlattened key: domain_key.region\nPer-domain replica_regions defaults empty\nOnly explicitly listed replica regions are created',370,390,1160,145,parent=resource)
    d.connect(inputs,domain,kind='dashed',exit=(1,.5),entry=(0,.9),waypoints=[(700,360),(700,520)])
    d.connect(domain,replicas,kind='dashed',straight=True)
    footer(d,'DEFAULT RESULT: No domains or replicas. Domain entries drive creation directly; list already-managed domains explicitly when maintaining configuration.\nPer-entry home_region does not reconfigure the shared provider endpoint. Review provider placement, domain/admin/license inputs and requested replica regions.\nNo users, applications, federation, MFA or access policies are configured by these two resource types.',990)
    return d


def entities(title,index,kind):
    d=header(title,index)
    home=d.group('other','Home-region IAM provider / coalesce(home_region, region)',20,160,2360,280)
    count=4 if kind=='multi' else 3 if kind=='workload' else 2
    d.icon('User Group',210,110,parent=home,size=58,label=f'{count} tenancy IAM groups\nNo users or memberships created',label_pos='top')
    roles=('Per entity: admins / auditors' if kind=='multi' else 'Workload admins / operators / auditors' if kind=='workload' else 'Entity admins / auditors')
    d.text(roles+'\nGroup names are generated or explicitly overridden.\nAn override changes the created group name; it is not an existing-group lookup.',410,75,1000,135,parent=home,size=14)
    policy=d.icon('Policies',1820,110,parent=home,size=58,label=f'{count} delegated IAM policies\nManage / '+('use / read' if kind=='workload' else 'read')+' all-resources within generated paths',label_pos='top')
    d.text('Policy placement: '+('per-entity policy compartment → per-entity parent → wrapper parent.' if kind=='multi' else 'policy_compartment_ocid override, otherwise the selected parent.'),30,230,1450,35,parent=home,size=12)
    parent=d.group('compartment','Selected parent compartment / parent_compartment_ocid falls back to tenancy',20,500,2360,590)
    roots=[]
    names=['Finance / code fin','Engineering / code eng'] if kind=='multi' else ['Workload / default code app'] if kind=='workload' else ['Operating entity / default code entity']
    children=['app','data','ops'] if kind=='workload' else ['platform','workloads','security']
    for k,name in enumerate(names):
        x=30+k*1160 if kind=='multi' else 30
        w=1120 if kind=='multi' else 2300
        root=d.group('compartment',name+' / created root compartment',x,80,w,430,parent=parent)
        roots.append(root)
        cw=(w-100)/3
        for j,child in enumerate(children):
            d.group('compartment',child+' / created child',25+j*(cw+20),100,cw,200,parent=root)
        d.text('Child map can be overridden. Root + child compartment paths feed delegated policies.',25,345,w-50,45,parent=root,size=12)
    for root in roots:
        d.connect(policy,root,kind='plain',exit=(.5,1),entry=(.5,0),waypoints=[(1840,470),(root.center()[0],470)])
    details={
        'single':'DEFAULT SHAPE: 1 root + 3 children; 2 IAM groups and 2 policies.\nAdministrators manage all-resources; auditors read all-resources in the generated entity root and child paths.',
        'multi':'DEFAULT SHAPE: Finance + Engineering, each with 1 root + 3 children; total 8 compartments, 4 groups and 4 policies.\nEach entity may override its parent, child map, names and policy compartment. Separate roots are delegation boundaries, not verified tenant isolation.',
        'workload':'DEFAULT SHAPE: 1 workload root + app/data/ops children; 3 groups and 3 policies.\nAdmins manage, operators use and auditors read all-resources in workload root and child paths. No approval portal or workload runtime is created.',
    }
    footer(d,details[kind]+'\nNo VCN, compute, database, users or membership assignments are created. enable_delete defaults true for the generated compartment package.')
    return d


def scca(title,index):
    note='SCCA-STYLE FOUNDATION: Core + hub/spoke network + optional OS Management Hub module.\nCloud Guard, Audit retention, Vault/KMS, VSS and Events are enabled. Firewall, Security Zones, Monitoring, Budgets and OS Management are disabled. No accreditation is implied.'
    d=base.build(title,'base',index,scope_note=note,subtitle=f'FOUNDATION / IDENTITY {index:02} / Official OCI Toolkit v24.2 / SCCA source defaults')
    panel=d.group('other','Core + operations detail / source-defined enablement',1760,160,740,1080)
    d.text('module.core / pinned Core, cis_level=level2\nCreates root + governance/security/network/workloads compartments,\n6 default IAM groups, 2 dynamic groups, scoped policies, tags and log groups.',20,70,700,100,parent=panel,size=13)
    for name,x,label in [('Cloud Guard',120,'Cloud Guard\nEnabled'),('Vault',370,'Vault + HSM key\nEnabled'),('Vulnerability Scanning',620,'VSS host scan\nEnabled')]:
        d.icon(name,x,280,parent=panel,size=56,label=label,label_pos='top')
    d.text('Cloud Guard configuration and Audit retention (365 days) target tenancy scope.\nCloud Guard target covers the Core root; recipe lists default empty.\nDefault Vault + AES key in security; VSS recipe/target for workloads.\nEnabled resources do not imply scanned workloads or detected findings.',20,360,700,125,parent=panel,size=13)
    d.box('Events + Notifications / enabled\nDefault IAM-change event rules and topic.\nSubscriptions default empty; delivery is not established by this diagram.',25,540,690,110,parent=panel)
    d.box('Optional controls / disabled by default\nNetwork Firewall; Security Zones; Monitoring; Budgets.\nOS Management Hub flag=false; managed-instance/job maps empty.',25,720,690,130,parent=panel,kind='optional')
    d.text('Network placement: network_compartment_ocid override,\notherwise module.core.network_compartment_id.\nThe left view is the default hub/spoke foundation only.\nAppliances, inserted inspection paths and application workloads are absent.',20,900,700,115,parent=panel,size=13)
    return d


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--render',action='store_true')
    args=parser.parse_args()
    for index,(slug,title,kind) in enumerate(ITEMS,6):
        d=domains(title,index) if kind=='domain' else scca(title,index) if kind=='scca' else entities(title,index,kind)
        warnings=d.check()
        print(slug,warnings,flush=True)
        if warnings:
            raise RuntimeError('Fix every layout warning before export')
        out=ROOT/'blueprints'/slug/'architecture/architecture.drawio'
        d.save(str(out))
        if args.render and not d.render(str(out.with_suffix('.png')),scale=1.5):
            raise RuntimeError('draw.io export failed')
        with out.open('a') as stream:
            stream.write('\n')


if __name__=='__main__':
    main()
