 /*------------------------------------------------------------------------
    File        : MockProcedureGeneratorTester
    Purpose     : Unit tests for MockProcedureGenerator class
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.
USING OEUnit.Assertion.*.
USING OEMock.Generation.*.
USING OEMock.Reflection.*.

ROUTINE-LEVEL ON ERROR UNDO, THROW.

CLASS OEMock.Tests.Generation.MockProcedureGeneratorTester:
    
    @Test.
    METHOD PUBLIC VOID ConstructorCreatesParameterOutputValues():
        DEFINE VARIABLE gen AS MockProcedureGenerator NO-UNDO.
        
        gen = NEW MockProcedureGenerator().
        
        Assert:IsTrue(VALID-OBJECT(gen:ParameterOutputValues)).
        
        IF VALID-OBJECT(gen) THEN DELETE OBJECT gen.
    END METHOD.
    
    @Test.
    METHOD PUBLIC VOID GenerateCallsOEMockRegisterMethodCall():
        DEFINE VARIABLE gen AS MockProcedureGenerator NO-UNDO.
        DEFINE VARIABLE res AS LONGCHAR NO-UNDO.
        
        gen = NEW MockProcedureGenerator().
        gen:AttachTo(CreateDummyProcedureWithParam()).
        ASSIGN res = gen:Generate() NO-ERROR.
        
        AssertString:Contains(gen:Generate(), "OEMockRegister:RegisterMethodCall(").
        
        IF VALID-OBJECT(gen) THEN DELETE OBJECT gen.
    END METHOD.
    
    @Test.
    METHOD PUBLIC VOID GenerateCallsOEMockRegisterMethodCallParam():
        DEFINE VARIABLE gen AS MockProcedureGenerator NO-UNDO.
        
        gen = NEW MockProcedureGenerator().
        gen:AttachTo(CreateDummyProcedureWithParam()).
        AssertString:Contains(gen:Generate(), "OEMockRegister:RegisterMethodCallParam(").
        
        FINALLY:
        IF VALID-OBJECT(gen) THEN DELETE OBJECT gen.
        END FINALLY.
    END METHOD.
    
    @Test.
    METHOD PUBLIC VOID GenerateProceduralCallsOEMockRegisterMethodCall():
        DEFINE VARIABLE gen AS MockProcedureGenerator NO-UNDO.
        
        gen = NEW MockProcedureGenerator().
        gen:AttachTo(CreateDummyProcedureWithParam()).
        
        AssertString:Contains(gen:GenerateProcedural(), "OEMockRegister:RegisterMethodCall(").
        
        IF VALID-OBJECT(gen) THEN DELETE OBJECT gen.
    END METHOD.
    
    @Test.
    METHOD PUBLIC VOID GenerateProceduralCallsOEMockRegisterMethodCallParam():
        DEFINE VARIABLE gen AS MockProcedureGenerator NO-UNDO.
        
        gen = NEW MockProcedureGenerator().
        gen:AttachTo(CreateDummyProcedureWithParam()).
        
        AssertString:Contains(gen:GenerateProcedural(), "OEMockRegister:RegisterMethodCallParam(").
        
        IF VALID-OBJECT(gen) THEN DELETE OBJECT gen.
    END METHOD.
    
    @Test.
    METHOD PUBLIC VOID AttachToAddsToGeneratorList():
        DEFINE VARIABLE gen AS MockProcedureGenerator NO-UNDO.
        DEFINE VARIABLE meth AS Procedure NO-UNDO.
        DEFINE VARIABLE genCount AS INTEGER NO-UNDO.
        
        meth = NEW Procedure("ProcName").
        genCount = meth:Generators:Count.
        
        gen = NEW MockProcedureGenerator().
        gen:AttachTo(meth).
        
        Assert:AreEqual(meth:Generators:Count, genCount + 1).
        
        IF VALID-OBJECT(gen)  THEN DELETE OBJECT gen.
        IF VALID-OBJECT(meth) THEN DELETE OBJECT meth.
        
    END METHOD.
    
    @Test.
    METHOD PUBLIC VOID SetParameterOutputValueSetsItemInList():
        DEFINE VARIABLE gen AS MockProcedureGenerator NO-UNDO.
        DEFINE VARIABLE meth AS Procedure NO-UNDO.
        DEFINE VARIABLE parm AS PrimitiveParameter NO-UNDO.
        
        meth = NEW Procedure("ProcName").
        parm = NEW PrimitiveParameter("Param1", "INTEGER").
        meth:Parameters:AddParameter(parm).
        
        gen = NEW MockProcedureGenerator().
        gen:AttachTo(meth).
        gen:SetParameterOutputValue("Param1", "1234").
        Assert:AreEqual(gen:ParameterOutputValues:GetValue("Param1"), "1234").
        
        IF VALID-OBJECT(gen)  THEN DELETE OBJECT gen.
        IF VALID-OBJECT(meth) THEN DELETE OBJECT meth.
        IF VALID-OBJECT(parm) THEN DELETE OBJECT parm.
        
    END METHOD.
    
    @Test.
    METHOD PUBLIC VOID SetParameterOutputValueFormatsCharacterParams():
        DEFINE VARIABLE gen AS MockProcedureGenerator NO-UNDO.
        DEFINE VARIABLE meth AS Procedure NO-UNDO.
        DEFINE VARIABLE parm AS PrimitiveParameter NO-UNDO.
        
        meth = NEW Procedure("ProcName").
        parm = NEW PrimitiveParameter("Param1", "CHARACTER").
        meth:Parameters:AddParameter(parm).
        
        gen = NEW MockProcedureGenerator().
        gen:AttachTo(meth).
        gen:SetParameterOutputValue("Param1", "Value1").
        Assert:AreEqual(gen:ParameterOutputValues:GetValue("Param1"), '"Value1"').
        
        gen:SetParameterOutputValue("Param1", "'Value2'").
        Assert:AreEqual(gen:ParameterOutputValues:GetValue("Param1"), "'Value2'").
        
        gen:SetParameterOutputValue("Param1", '"Value3"').
        Assert:AreEqual(gen:ParameterOutputValues:GetValue("Param1"), '"Value3"').
        
        IF VALID-OBJECT(gen)  THEN DELETE OBJECT gen.
        IF VALID-OBJECT(meth) THEN DELETE OBJECT meth.
        IF VALID-OBJECT(parm) THEN DELETE OBJECT parm.
        
    END METHOD.
    
    @Test.
    METHOD PUBLIC VOID GenerateReturnsParameterAssignment():
        DEFINE VARIABLE gen AS MockProcedureGenerator NO-UNDO.
        DEFINE VARIABLE meth AS Procedure NO-UNDO.
        DEFINE VARIABLE parm AS PrimitiveParameter NO-UNDO.
        
        meth = NEW Procedure("ProcName").
        parm = NEW PrimitiveParameter("Param1", "INTEGER").
        meth:Parameters:AddParameter(parm).
        
        gen = NEW MockProcedureGenerator().
        gen:AttachTo(meth).
        gen:SetParameterOutputValue("Param1", "1234").
        
        AssertString:Contains(gen:GenerateProcedural(), "Param1 = 1234").
        
        IF VALID-OBJECT(gen)  THEN DELETE OBJECT gen.
        IF VALID-OBJECT(meth) THEN DELETE OBJECT meth.
        IF VALID-OBJECT(parm) THEN DELETE OBJECT parm.
        
    END METHOD.
    
    @Test.
    METHOD PUBLIC VOID GenerateReturnsMultipleParameterAssignment():
        DEFINE VARIABLE gen AS MockProcedureGenerator NO-UNDO.
        DEFINE VARIABLE meth AS Procedure NO-UNDO.
        DEFINE VARIABLE parm AS PrimitiveParameter NO-UNDO.
        DEFINE VARIABLE parm2 AS PrimitiveParameter NO-UNDO.
        DEFINE VARIABLE res AS LONGCHAR NO-UNDO.

        meth  = NEW Procedure("ProcName").
        parm  = NEW PrimitiveParameter("Param1", "INTEGER").
        parm2 = NEW PrimitiveParameter("Param2", "INTEGER").
        meth:Parameters:AddParameter(parm).
        meth:Parameters:AddParameter(parm2).
        
        gen = NEW MockProcedureGenerator().
        gen:AttachTo(meth).
        gen:SetParameterOutputValue("Param1", "1234").
        gen:SetParameterOutputValue("Param2", "5678").
        
        res = gen:GenerateProcedural().        
        AssertString:Contains(res, "Param1 = 1234").
        AssertString:Contains(res, "Param2 = 5678").
        
        IF VALID-OBJECT(gen)   THEN DELETE OBJECT gen.
        IF VALID-OBJECT(meth)  THEN DELETE OBJECT meth.
        IF VALID-OBJECT(parm)  THEN DELETE OBJECT parm.
        IF VALID-OBJECT(parm ) THEN DELETE OBJECT parm2.
        
    END METHOD.
    
    @Test.
    METHOD PUBLIC VOID GenerateReturnsNullParameterAssignment():
        DEFINE VARIABLE gen AS MockProcedureGenerator NO-UNDO.
        DEFINE VARIABLE meth AS Procedure NO-UNDO.
        DEFINE VARIABLE parm AS PrimitiveParameter NO-UNDO.
        
        meth = NEW Procedure("ProcName").
        parm = NEW PrimitiveParameter("Param1", "INTEGER").
        meth:Parameters:AddParameter(parm).
        
        gen = NEW MockProcedureGenerator().
        gen:AttachTo(meth).
        gen:SetParameterOutputValue("Param1", ?).
        
        AssertString:Contains(gen:GenerateProcedural(), "Param1 = ?").
        
        IF VALID-OBJECT(gen)  THEN DELETE OBJECT gen.
        IF VALID-OBJECT(meth) THEN DELETE OBJECT meth.
        IF VALID-OBJECT(parm) THEN DELETE OBJECT parm.
        
    END METHOD.
    
    METHOD PROTECTED Procedure CreateDummyProcedureWithParam():
        DEFINE VARIABLE meth AS Procedure NO-UNDO.
        DEFINE VARIABLE parm AS PrimitiveParameter NO-UNDO.
        
        meth = NEW Procedure("ProcName").
        parm = NEW PrimitiveParameter("Param1", "INTEGER").
        meth:Parameters:AddParameter(parm).
        
        RETURN meth.
        
    END METHOD.

END CLASS.