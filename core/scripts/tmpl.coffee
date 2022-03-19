tmpls = {}
profileTpl = """
    <li class="mochi_list_item profile" name="{{=it.name}}">
        <input name="profile" class="mochi_radio widget" type="radio" value="{{=it.name}}"/>
        <a class="value edit" href="\#{{=it.name}}" title="edit"></a>
        <label class="label">{{=it.name}}</label>
        <sup class="ping"></sup><sup class="rate"></sup>
    </li>"""

tmpls['profile'] = doT.template(profileTpl)

root = exports ? this
root.tmpls = tmpls
