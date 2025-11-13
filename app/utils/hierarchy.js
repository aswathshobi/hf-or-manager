export function buildHierarchy(employees) {
  if (!employees || employees.length === 0) return [];

  const employeeList = employees.map(emp => ({
    id: emp.id,
    name: emp.name || '',
    designation: emp.designation || '',
    team: emp.team || '',
    managerId: emp.manager?.get ? emp.manager.get('id') : emp.manager
  }));


  const roots = employeeList.filter(emp => !emp.managerId || emp.managerId === null);
  
  if (roots.length === 0 && employeeList.length > 0) {

    return [employeeList[0]];
  }

  if (roots.length > 1) {
    console.warn('Multiple root employees found, using only the first one:', roots[0]);
    return [roots[0]];
  }


  const addChildren = (parent) => {
    const children = employeeList.filter(emp => emp.managerId === parent.id);
    if (children.length > 0) {
      parent._children = children.map(child => {
        const childWithChildren = { ...child };
        addChildren(childWithChildren);
        return childWithChildren;
      });
    }
    return parent;
  };

  return roots.map(root => addChildren({ ...root }));
}

export function convertToD3Format(employees) {
  const hierarchy = buildHierarchy(employees);
  
  if (hierarchy.length === 0) {
    return [];
  }

  const flatData = [];
  
  const flatten = (node, parentId = '') => {
    flatData.push({
      id: node.id,
      parentId: parentId || '',
      name: node.name,
      designation: node.designation,
      team: node.team
    });
    
    if (node._children) {
      node._children.forEach(child => flatten(child, node.id));
    }
  };

  flatten(hierarchy[0]);
  return flatData;
}
