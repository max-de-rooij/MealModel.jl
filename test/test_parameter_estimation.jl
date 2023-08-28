# using MealModel
# using Test

# # Define assimilation tests

# @testset "Create TimedVector object" begin
#   function create_timedvector()
    
#     TimedVector([1., 2., 3.], [1:3...])

#     true
#   end

#   function error_timedvector()

#     try
#       TimedVector([1., 2., 3.], [1:2...])
#     catch
#       return true
#     end
    

#     return false
#   end
      

#   @test create_timedvector()
#   @test error_timedvector()
# end

# @testset "Create MealResponseData" begin
#   function complete_meal_resp()
    
#     glc = [4.97828626648081,	9.83226219754181,	6.91736265000290,	3.99736583151076,	4.74531292225800,	5.43827322143290,	5.00061029702766,	4.90628637452010]
#     ins = [21.7542994608033,	287.361969174996,	294.323541530305,	85.4388252908261,	18.0684917209633,	21.0182483747640,	23.1679411923448,	21.8618244436204]
#     trg = [1.16871366007653,	1.58440178335270,	1.78195011372397,	2.39301829368748,	2.41622964225137,	2.31174933441785,	1.93219870120156,	1.72103932334563]
#     nfa = [0.335735045292724,	0.306808022891325,	0.175773322340940,	0.126453528770619,	0.186422309973495,	0.317877874980899,	0.504623299086489,	0.561199670138616]

#     time = [0.,30.,60.,120.,180.,240.,360.,480.]

#     glc = TimedVector(glc, time)
#     ins = TimedVector(ins, time)
#     trg = TimedVector(trg, time)
#     nfa = TimedVector(nfa, time)

#     CompleteMealResponse(glc, ins, trg, nfa)
#     true
#   end

#   @test complete_meal_resp()
# end

# @testset "Create Loss Function" begin
#   function create_loss_f()
#     glc = [4.97828626648081,	9.83226219754181,	6.91736265000290,	3.99736583151076,	4.74531292225800,	5.43827322143290,	5.00061029702766,	4.90628637452010]
#     ins = [21.7542994608033,	287.361969174996,	294.323541530305,	85.4388252908261,	18.0684917209633,	21.0182483747640,	23.1679411923448,	21.8618244436204]
#     trg = [1.16871366007653,	1.58440178335270,	1.78195011372397,	2.39301829368748,	2.41622964225137,	2.31174933441785,	1.93219870120156,	1.72103932334563]
#     nfa = [0.335735045292724,	0.306808022891325,	0.175773322340940,	0.126453528770619,	0.186422309973495,	0.317877874980899,	0.504623299086489,	0.561199670138616]

#     time = [0.,30.,60.,120.,180.,240.,360.,480.]

#     glc = TimedVector(glc, time)
#     ins = TimedVector(ins, time)
#     trg = TimedVector(trg, time)
#     nfa = TimedVector(nfa, time)

#     data = CompleteMealResponse(glc, ins, trg, nfa)

#     model = MixedMealModel(75000., 60000., 85., glc.values[1], ins.values[1], trg.values[1], nfa.values[1])
#     options = DefaultModelOptions(model)

#     setup(model, data, options)
#     true
#   end

#   function test_loss_f()
#     glc = [4.97828626648081,	9.83226219754181,	6.91736265000290,	3.99736583151076,	4.74531292225800,	5.43827322143290,	5.00061029702766,	4.90628637452010]
#     ins = [21.7542994608033,	287.361969174996,	294.323541530305,	85.4388252908261,	18.0684917209633,	21.0182483747640,	23.1679411923448,	21.8618244436204]
#     trg = [1.16871366007653,	1.58440178335270,	1.78195011372397,	2.39301829368748,	2.41622964225137,	2.31174933441785,	1.93219870120156,	1.72103932334563]
#     nfa = [0.335735045292724,	0.306808022891325,	0.175773322340940,	0.126453528770619,	0.186422309973495,	0.317877874980899,	0.504623299086489,	0.561199670138616]

#     time = [0.,30.,60.,120.,180.,240.,360.,480.]

#     glc = TimedVector(glc, time)
#     ins = TimedVector(ins, time)
#     trg = TimedVector(trg, time)
#     nfa = TimedVector(nfa, time)

#     data = CompleteMealResponse(glc, ins, trg, nfa)

#     model = MixedMealModel(75000., 60000., 85., glc.values[1], ins.values[1], trg.values[1], nfa.values[1])
#     options = DefaultModelOptions(model)

#     optprob = setup(model, data, options)
#     func = optprob.f
#     func(optprob.u0, 0.)
#     true
#   end

#   @test create_loss_f()
#   @test test_loss_f()
# end